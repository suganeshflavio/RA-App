import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/student_test.dart';
import '../models/video_lesson.dart';
import '../repositories/student_test_repository.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.video});

  final VideoLesson video;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final StudentTestRepository _repository = StudentTestRepository(ApiClient());

  late Future<List<StudentTest>> _testsFuture;

  StudentTest? _activeTest;
  StudentTest? _lastSubmittedTest;
  DateTime? _startedAt;
  bool _isSubmitting = false;
  bool _isLoadingTest = false;
  String? _loadingTestId;
  StudentAttemptResult? _result;

  final Map<String, String> _answersByQuestionId = <String, String>{};

  @override
  void initState() {
    super.initState();
    _testsFuture = _repository.fetchTestsByVideo(widget.video.id);
  }

  Future<void> _loadTest(String testId) async {
    setState(() {
      _isLoadingTest = true;
      _loadingTestId = testId;
      _activeTest = null;
      _startedAt = null;
      _result = null;
      _answersByQuestionId.clear();
    });

    try {
      final fullTest = await _repository.fetchTestById(testId);
      if (!mounted) return;
      setState(() {
        _activeTest = fullTest;
        _startedAt = DateTime.now().toUtc();
      });
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'Unable to load test.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTest = false;
          _loadingTestId = null;
        });
      }
    }
  }

  Future<void> _submit() async {
    final test = _activeTest;
    final startedAt = _startedAt;
    if (test == null || startedAt == null || _isSubmitting) return;

    final total = test.questions.length;
    if (_answersByQuestionId.length != total) {
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

    final invalidSelection = _answersByQuestionId.values.any(
      (value) => value != 'A' && value != 'B' && value != 'C' && value != 'D',
    );
    if (invalidSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('Invalid option detected.'),
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
        videoId: test.videoId.isNotEmpty ? test.videoId : widget.video.id,
        startedAt: startedAt,
        submittedAt: DateTime.now().toUtc(),
        answers: answers,
        status: 'COMPLETED',
      );

      if (!mounted) return;
      setState(() {
        _result = result;
        _lastSubmittedTest = test;
        _activeTest = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('Test submitted successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException
          ? e.message
          : 'Unable to submit attempt.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQ Assessment'),
      ),
      body: AppBackground(
        child: FutureBuilder<List<StudentTest>>(
          future: _testsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Unable to load tests.';
              return _ErrorView(
                message: message,
                onRetry: () {
                  setState(() {
                    _testsFuture = _repository.fetchTestsByVideo(widget.video.id);
                  });
                },
              );
            }

            final tests = snapshot.data ?? <StudentTest>[];
            if (tests.isEmpty) {
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
                        'No MCQ / Tests available for this video yet.',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_activeTest == null) {
              if (_result != null && _lastSubmittedTest != null) {
                return _SubmittedResultView(
                  test: _lastSubmittedTest!,
                  result: _result!,
                  onRetry: () {
                    setState(() {
                      _result = null;
                      _lastSubmittedTest = null;
                      _answersByQuestionId.clear();
                    });
                  },
                  onStartAgain: () {
                    setState(() {
                      _result = null;
                      _lastSubmittedTest = null;
                      _answersByQuestionId.clear();
                      _activeTest = null;
                      _startedAt = null;
                    });
                  },
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(18),
                itemCount: tests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final test = tests[index];
                  final isCompleted =
                      _result != null && _lastSubmittedTest?.id == test.id;
                  final isThisTestLoading =
                      _isLoadingTest && _loadingTestId == test.id;

                  return AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.testName,
                          style: AppTypography.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${test.totalQuestions} questions • ${test.marksPerQuestion} mark(s) each',
                          style: AppTypography.labelSmall,
                        ),
                        if (isCompleted && _result != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Score: ${_result!.obtainedMarks}/${_result!.totalMarks} '
                              '(Correct: ${_result!.correctAnswers}, Wrong: ${_result!.wrongAnswers})',
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 14,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        AppPrimaryButton(
                          text: isThisTestLoading
                              ? 'Loading Test...'
                              : isCompleted
                              ? 'Retake MCQ'
                              : 'Start MCQ',
                          icon: isThisTestLoading
                              ? null
                              : Icons.play_arrow_rounded,
                          isLoading: isThisTestLoading,
                          onPressed: _isLoadingTest ? null : () => _loadTest(test.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

          final test = _activeTest!;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: test.questions.length,
                  itemBuilder: (context, index) {
                    final question = test.questions[index];
                    final selected = _answersByQuestionId[question.id];
                    final isSubmitted = _result != null;
                    final selectedIsCorrect =
                        selected != null && selected == question.correctOption;
                    final correctLabel = question.correctOption.isEmpty
                        ? ''
                        : 'Correct answer: ${question.correctOption}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFDDBF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}. ${question.question}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3A1E0B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...question.options.entries.map((entry) {
                            final isSelected = selected == entry.key;
                            final isCorrectChoice =
                                entry.key == question.correctOption;
                            final tileColor = isSubmitted
                                ? isCorrectChoice
                                      ? const Color(0xFFE9F9EF)
                                      : isSelected
                                      ? const Color(0xFFFFEAEA)
                                      : Colors.white
                                : isSelected
                                ? const Color(0xFFFFF1E7)
                                : Colors.white;
                            final borderColor = isSubmitted
                                ? isCorrectChoice
                                      ? const Color(0xFF2EAE66)
                                      : isSelected
                                      ? const Color(0xFFE75F5F)
                                      : const Color(0xFFFFDDBF)
                                : isSelected
                                ? const Color(0xFFF97316)
                                : const Color(0xFFFFDDBF);
                            final iconColor = isSubmitted
                                ? isCorrectChoice
                                      ? const Color(0xFF2EAE66)
                                      : isSelected
                                      ? const Color(0xFFE75F5F)
                                      : const Color(0xFF8F6A4D)
                                : isSelected
                                ? const Color(0xFFF97316)
                                : const Color(0xFF8F6A4D);

                            final optionIcon = isSubmitted && isCorrectChoice
                                ? Icons.check_circle_rounded
                                : isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: isSubmitted
                                    ? null
                                    : () {
                                        setState(() {
                                          _answersByQuestionId[question.id] =
                                              entry.key;
                                        });
                                      },
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
                                    children: [
                                      Icon(optionIcon, color: iconColor),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${entry.key}. ${entry.value}',
                                          style: TextStyle(
                                            color:
                                                isSubmitted && isCorrectChoice
                                                ? const Color(0xFF1D7C4D)
                                                : isSelected
                                                ? const Color(0xFFB33A3A)
                                                : const Color(0xFF3A1E0B),
                                            fontWeight:
                                                isSubmitted && isCorrectChoice
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (isSubmitted) ...[
                            const SizedBox(height: 10),
                            if (selectedIsCorrect ||
                                correctLabel.isNotEmpty ||
                                question.answerExplanation.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selectedIsCorrect
                                      ? const Color(0xFFE9F9EF)
                                      : const Color(0xFFFFF1F1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (selectedIsCorrect ||
                                        correctLabel.isNotEmpty)
                                      Text(
                                        selectedIsCorrect
                                            ? 'Correct answer selected.'
                                            : correctLabel,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: selectedIsCorrect
                                              ? const Color(0xFF1D7C4D)
                                              : const Color(0xFFB33A3A),
                                        ),
                                      ),
                                    if (question
                                        .answerExplanation
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Explanation: ${question.answerExplanation}',
                                        style: const TextStyle(
                                          color: Color(0xFF3A1E0B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF6EE),
                  border: Border(top: BorderSide(color: Color(0xFFFFDDBF))),
                ),
                child: Column(
                  children: [
                    if (_result != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Score: ${_result!.obtainedMarks}/${_result!.totalMarks} '
                          '(Correct: ${_result!.correctAnswers}, Wrong: ${_result!.wrongAnswers})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3A1E0B),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => setState(() {
                                    _activeTest = null;
                                    _startedAt = null;
                                    _answersByQuestionId.clear();
                                    if (_result == null) {
                                      _lastSubmittedTest = null;
                                    }
                                  }),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF97316),
                              side: const BorderSide(color: Color(0xFFF97316)),
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: Text(
                              _isSubmitting ? 'Submitting...' : 'Submit Test',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
}

class _SubmittedResultView extends StatelessWidget {
  const _SubmittedResultView({
    required this.test,
    required this.result,
    required this.onRetry,
    required this.onStartAgain,
  });

  final StudentTest test;
  final StudentAttemptResult result;
  final VoidCallback onRetry;
  final VoidCallback onStartAgain;

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
            border: Border.all(color: const Color(0xFFFFDDBF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                test.testName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3A1E0B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Score: ${result.obtainedMarks}/${result.totalMarks} '
                '(Correct: ${result.correctAnswers}, Wrong: ${result.wrongAnswers})',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3A1E0B),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRetry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF97316),
                        side: const BorderSide(color: Color(0xFFF97316)),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onStartAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Try Again'),
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
              border: Border.all(color: const Color(0xFFFFDDBF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${index + 1}. ${question.question}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A1E0B),
                  ),
                ),
                const SizedBox(height: 10),
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
                      : const Color(0xFFFFDDBF);
                  final textColor = isCorrectChoice
                      ? const Color(0xFF1D7C4D)
                      : isSelected
                      ? const Color(0xFFB33A3A)
                      : const Color(0xFF3A1E0B);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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
                          Expanded(
                            child: Text(
                              '${entry.key}. ${entry.value}',
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
                    child: Text(
                      'Explanation: $explanation',
                      style: const TextStyle(color: Color(0xFF3A1E0B)),
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
              style: const TextStyle(color: Color(0xFF6E4D37)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
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
