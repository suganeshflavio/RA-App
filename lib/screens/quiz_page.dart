import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/student_test.dart';
import '../repositories/student_test_repository.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_card.dart';
import '../widgets/rich_content_view.dart';

/// A single MCQ test, one question per screen. Reached either directly by
/// [testId] (the flat "MCQ Test" course category, or a topic's MCQ tile).
/// [videoId] is passed through to the attempt only when this test was
/// reached via a topic that also has a linked video.
class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    required this.testId,
    this.videoId,
    this.title,
  });

  final String testId;
  final String? videoId;
  final String? title;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final StudentTestRepository _repository = StudentTestRepository(ApiClient());

  late Future<StudentTest> _testFuture;
  DateTime? _startedAt;
  int _currentIndex = 0;
  bool _isSubmitting = false;
  StudentAttemptResult? _result;
  StudentTest? _submittedTest;

  final Map<String, String> _answersByQuestionId = <String, String>{};

  @override
  void initState() {
    super.initState();
    _testFuture = _load();
  }

  Future<StudentTest> _load() async {
    final test = await _repository.fetchTestById(widget.testId);
    _startedAt = DateTime.now().toUtc();
    return test;
  }

  void _retry() {
    setState(() {
      _testFuture = _load();
      _currentIndex = 0;
      _answersByQuestionId.clear();
      _result = null;
      _submittedTest = null;
    });
  }

  void _selectAnswer(String questionId, String option) {
    setState(() => _answersByQuestionId[questionId] = option);
  }

  void _goPrevious() {
    if (_currentIndex > 0) setState(() => _currentIndex -= 1);
  }

  void _goNext(int totalQuestions) {
    if (_currentIndex < totalQuestions - 1) {
      setState(() => _currentIndex += 1);
    }
  }

  Future<void> _submit(StudentTest test) async {
    final startedAt = _startedAt;
    if (startedAt == null || _isSubmitting) return;

    if (_answersByQuestionId.length != test.questions.length) {
      final firstUnanswered = test.questions.indexWhere(
        (q) => !_answersByQuestionId.containsKey(q.id),
      );
      if (firstUnanswered != -1) {
        setState(() => _currentIndex = firstUnanswered);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('Please answer all questions before submitting.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final answers = test.questions
          .map(
            (question) => AttemptAnswer(
              questionId: question.id,
              selected: _answersByQuestionId[question.id]!,
            ),
          )
          .toList(growable: false);

      final result = await _repository.submitAttempt(
        testId: test.id,
        videoId: widget.videoId,
        startedAt: startedAt,
        submittedAt: DateTime.now().toUtc(),
        answers: answers,
        status: 'COMPLETED',
      );

      if (!mounted) return;
      setState(() {
        _result = result;
        _submittedTest = test;
      });
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'Unable to submit attempt.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'MCQ Assessment'),
      ),
      body: AppBackground(
        child: FutureBuilder<StudentTest>(
          future: _testFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Unable to load this test.';
              return _ErrorView(message: message, onRetry: _retry);
            }

            final test = snapshot.data!;

            if (test.questions.isEmpty) {
              return Center(
                child: AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.quiz_outlined,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This test has no questions yet.',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_result != null && _submittedTest != null) {
              return _SubmittedResultView(test: _submittedTest!, result: _result!);
            }

            return _QuestionPager(
              test: test,
              currentIndex: _currentIndex,
              answersByQuestionId: _answersByQuestionId,
              isSubmitting: _isSubmitting,
              onSelectAnswer: _selectAnswer,
              onPrevious: _goPrevious,
              onNext: () => _goNext(test.questions.length),
              onSubmit: () => _submit(test),
            );
          },
        ),
      ),
    );
  }
}

class _QuestionPager extends StatelessWidget {
  const _QuestionPager({
    required this.test,
    required this.currentIndex,
    required this.answersByQuestionId,
    required this.isSubmitting,
    required this.onSelectAnswer,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final StudentTest test;
  final int currentIndex;
  final Map<String, String> answersByQuestionId;
  final bool isSubmitting;
  final void Function(String questionId, String option) onSelectAnswer;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final total = test.questions.length;
    final question = test.questions[currentIndex];
    final selected = answersByQuestionId[question.id];
    final isLast = currentIndex == total - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${currentIndex + 1} of $total',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / total,
                  minHeight: 6,
                  backgroundColor: AppColors.primaryLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichContentView(
                      html: question.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...question.options.entries.map((entry) {
                      final isSelected = selected == entry.key;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => onSelectAnswer(question.id, entry.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? AppColors.secondary
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${entry.key}.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.secondary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: RichContentView(
                                    html: entry.value,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.secondary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: currentIndex == 0 ? null : onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : (isLast ? onSubmit : onNext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: Text(
                    isSubmitting ? 'Submitting...' : (isLast ? 'Submit Test' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubmittedResultView extends StatelessWidget {
  const _SubmittedResultView({required this.test, required this.result});

  final StudentTest test;
  final StudentAttemptResult result;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                test.testName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Score: ${result.obtainedMarks}/${result.totalMarks} '
                '(Correct: ${result.correctAnswers}, Wrong: ${result.wrongAnswers})',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...test.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final review = result.questions.firstWhere(
            (item) => item.questionId == question.id,
            orElse: () => StudentAttemptQuestionReview(
              questionId: question.id,
              question: question.question,
              selected: '',
              correctOption: question.correctOption,
              answerExplanation: question.answerExplanation,
            ),
          );
          final selected = review.selected.isEmpty ? '' : review.selected;
          final correct = review.correctOption.isEmpty
              ? question.correctOption
              : review.correctOption;
          final explanation = review.answerExplanation.isEmpty
              ? question.answerExplanation
              : review.answerExplanation;
          final isSelectedWrong = selected.isNotEmpty && selected != correct;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q${index + 1}.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichContentView(
                        html: question.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...question.options.entries.map((entry) {
                  final isSelected = selected == entry.key;
                  final isCorrectChoice = entry.key == correct;
                  final tileColor = isCorrectChoice
                      ? const Color(0xFFE9F9EF)
                      : isSelected
                      ? const Color(0xFFFFEAEA)
                      : Colors.white;
                  final borderColor = isCorrectChoice
                      ? const Color(0xFF2EAE66)
                      : isSelected
                      ? const Color(0xFFE75F5F)
                      : AppColors.cardBorder;
                  final textColor = isCorrectChoice
                      ? const Color(0xFF1D7C4D)
                      : isSelected
                      ? const Color(0xFFB33A3A)
                      : AppColors.textPrimary;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isCorrectChoice
                                ? Icons.check_circle_rounded
                                : isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isCorrectChoice
                                ? const Color(0xFF2EAE66)
                                : isSelected
                                ? const Color(0xFFE75F5F)
                                : const Color(0xFF8F6A4D),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${entry.key}.',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isCorrectChoice
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: RichContentView(
                              html: entry.value,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: isCorrectChoice
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (selected.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selected: $selected',
                    style: TextStyle(
                      color: isSelectedWrong
                          ? const Color(0xFFB33A3A)
                          : const Color(0xFF6E4D37),
                      fontWeight: isSelectedWrong
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
                if (correct.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Correct answer: $correct',
                    style: const TextStyle(
                      color: Color(0xFF1D7C4D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelectedWrong
                          ? const Color(0xFFFFF1F1)
                          : const Color(0xFFE9F9EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explanation:',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichContentView(
                            html: explanation,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
