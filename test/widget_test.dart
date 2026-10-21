// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/app.dart';
import 'package:my_app/core/config/env.dart';
import 'package:my_app/models/student_test.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('Splash redirects to login', (WidgetTester tester) async {
    await tester.pumpWidget(const TksApp());

    expect(find.text('TKS Academy'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  test('Student quiz question exposes the correct option and explanation', () {
    final question = StudentTestQuestion.fromJson({
      'id': 'q1',
      'question': 'Who is the founder?',
      'optionA': 'Alice',
      'optionB': 'Bob',
      'optionC': 'Carol',
      'optionD': 'David',
      'correctOption': 'B',
      'answerExplanation':
          'Bob is the founder because he established the academy.',
    });

    expect(question.correctOption, 'B');
    expect(
      question.answerExplanation,
      'Bob is the founder because he established the academy.',
    );
    expect(question.options['B'], 'Bob');
  });

  test('Submit result parser accepts alternate backend field names', () {
    final result = StudentAttemptResult.fromJson({
      'id': 'attempt_1',
      'status': 'COMPLETED',
      'totalQuestions': 1,
      'correctAnswers': 1,
      'wrongAnswers': 0,
      'totalMarks': 2,
      'obtainedMarks': 2,
      'submittedAt': '2026-08-13T10:00:00.000Z',
      'questions': [
        {
          'question_id': 'q1',
          'question': 'Who is the founder?',
          'selected_option': 'B',
          'correct_answer': 'B',
          'explanation':
              'Bob is the founder because he established the academy.',
        },
      ],
    });

    expect(result.questions.length, 1);
    expect(result.questions.first.selected, 'B');
    expect(result.questions.first.correctOption, 'B');
    expect(
      result.questions.first.answerExplanation,
      'Bob is the founder because he established the academy.',
    );
  });

  test('Submit result parser accepts actual backend answer payload', () {
    final result = StudentAttemptResult.fromJson({
      'id': 'attempt_1',
      'status': 'COMPLETED',
      'totalQuestions': 2,
      'correctAnswers': 2,
      'wrongAnswers': 0,
      'totalMarks': 4,
      'obtainedMarks': 4,
      'submittedAt': '2026-08-13T12:58:08.232Z',
      'answers': [
        {
          'questionId': 'cmsrhjs5v0036og0pu0jmg326',
          'question': 'wht us what',
          'optionA': 'w',
          'optionB': 'wh',
          'optionC': 'wha',
          'optionD': 'what',
          'correctOption': 'D',
          'selected': 'D',
          'correct': true,
          'explanation': 'what',
        },
        {
          'questionId': 'cmsrhjs5v0037og0pxhonya95',
          'question': 'wher eis where',
          'optionA': 'wher',
          'optionB': 'w',
          'optionC': 'whe',
          'optionD': 'where',
          'correctOption': 'D',
          'selected': 'D',
          'correct': true,
          'explanation': 'where',
        },
      ],
    });

    expect(result.questions.length, 2);
    expect(result.questions.first.selected, 'D');
    expect(result.questions.first.correctOption, 'D');
    expect(result.questions.first.answerExplanation, 'what');
    expect(result.questions.last.answerExplanation, 'where');
  });
}
