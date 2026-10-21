class StudentTestListResponse {
  const StudentTestListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final List<StudentTest> data;

  factory StudentTestListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? <dynamic>[];
    return StudentTestListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unable to load tests.',
      data: rawList
          .map((item) => StudentTest.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StudentTestResponse {
  const StudentTestResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final StudentTest? data;

  factory StudentTestResponse.fromJson(Map<String, dynamic> json) {
    return StudentTestResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unable to load test.',
      data: json['data'] == null
          ? null
          : StudentTest.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class StudentTest {
  const StudentTest({
    required this.id,
    required this.videoId,
    required this.testName,
    required this.marksPerQuestion,
    required this.createdAt,
    required this.updatedAt,
    required this.video,
    required this.questions,
  });

  final String id;
  final String videoId;
  final String testName;
  final int marksPerQuestion;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final StudentTestVideo? video;
  final List<StudentTestQuestion> questions;

  int get totalQuestions => questions.length;

  factory StudentTest.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? <dynamic>[];

    return StudentTest(
      id: json['id'] as String? ?? '',
      videoId: json['videoId'] as String? ?? '',
      testName: json['testName'] as String? ?? 'Untitled Test',
      marksPerQuestion: (json['marksPerQuestion'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(json['createdAt'] as String?),
      updatedAt: _parseDateTime(json['updatedAt'] as String?),
      video: json['video'] == null
          ? null
          : StudentTestVideo.fromJson(json['video'] as Map<String, dynamic>),
      questions: rawQuestions
          .map(
            (item) =>
                StudentTestQuestion.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class StudentTestQuestion {
  const StudentTestQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    this.correctOption = '',
    this.answerExplanation = '',
  });

  final String id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String answerExplanation;

  Map<String, String> get options => {
    'A': optionA,
    'B': optionB,
    'C': optionC,
    'D': optionD,
  };

  factory StudentTestQuestion.fromJson(Map<String, dynamic> json) {
    final rawCorrectOption =
        (json['correctOption'] ?? json['correct_option']) as String? ?? '';
    final rawAnswerExplanation =
        (json['answerExplanation'] ??
                json['answer_explanation'] ??
                json['explanation'] ??
                json['correctAnswerExplanation'] ??
                json['correct_answer_explanation'])
            as String? ??
        '';

    return StudentTestQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      optionA: json['optionA'] as String? ?? '',
      optionB: json['optionB'] as String? ?? '',
      optionC: json['optionC'] as String? ?? '',
      optionD: json['optionD'] as String? ?? '',
      correctOption: rawCorrectOption.trim(),
      answerExplanation: rawAnswerExplanation.trim(),
    );
  }
}

class StudentTestVideo {
  const StudentTestVideo({
    required this.id,
    required this.videoName,
    required this.subject,
    required this.chapter,
    required this.course,
  });

  final String id;
  final String videoName;
  final String subject;
  final String chapter;
  final StudentTestCourse? course;

  factory StudentTestVideo.fromJson(Map<String, dynamic> json) {
    return StudentTestVideo(
      id: json['id'] as String? ?? '',
      videoName: json['videoName'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      chapter: json['chapter'] as String? ?? '',
      course: json['course'] == null
          ? null
          : StudentTestCourse.fromJson(json['course'] as Map<String, dynamic>),
    );
  }
}

class StudentTestCourse {
  const StudentTestCourse({required this.id, required this.courseName});

  final String id;
  final String courseName;

  factory StudentTestCourse.fromJson(Map<String, dynamic> json) {
    return StudentTestCourse(
      id: json['id'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
    );
  }
}

class SubmitAttemptResponse {
  const SubmitAttemptResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final StudentAttemptResult? data;

  factory SubmitAttemptResponse.fromJson(Map<String, dynamic> json) {
    return SubmitAttemptResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unable to submit attempt.',
      data: json['data'] == null
          ? null
          : StudentAttemptResult.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class StudentAttemptQuestionReview {
  const StudentAttemptQuestionReview({
    required this.questionId,
    required this.question,
    required this.selected,
    required this.correctOption,
    required this.answerExplanation,
  });

  final String questionId;
  final String question;
  final String selected;
  final String correctOption;
  final String answerExplanation;

  factory StudentAttemptQuestionReview.fromJson(Map<String, dynamic> json) {
    final questionId =
        (json['questionId'] as String? ??
                json['question_id'] as String? ??
                json['id'] as String? ??
                '')
            .trim();

    final selected =
        (json['selected'] as String? ??
                json['selected_option'] as String? ??
                json['selectedOption'] as String? ??
                json['answer'] as String? ??
                json['userAnswer'] as String? ??
                '')
            .toString()
            .trim();

    final correctOption =
        (json['correctOption'] as String? ??
                json['correct_option'] as String? ??
                json['correct_option_answer'] as String? ??
                json['correctAnswer'] as String? ??
                json['correct_answer'] as String? ??
                json['answer'] as String? ??
                '')
            .toString()
            .trim();

    final explanation =
        (json['answerExplanation'] as String? ??
                json['answer_explanation'] as String? ??
                json['explanation'] as String? ??
                json['correctAnswerExplanation'] as String? ??
                json['correct_answer_explanation'] as String? ??
                json['reason'] as String? ??
                '')
            .toString()
            .trim();

    return StudentAttemptQuestionReview(
      questionId: questionId,
      question: (json['question'] as String? ?? '').trim(),
      selected: selected,
      correctOption: correctOption,
      answerExplanation: explanation,
    );
  }
}

class StudentAttemptResult {
  const StudentAttemptResult({
    required this.id,
    required this.status,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.submittedAt,
    this.questions = const <StudentAttemptQuestionReview>[],
  });

  final String id;
  final String status;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalMarks;
  final int obtainedMarks;
  final DateTime? submittedAt;
  final List<StudentAttemptQuestionReview> questions;

  factory StudentAttemptResult.fromJson(Map<String, dynamic> json) {
    final rawQuestions =
        (json['questions'] as List<dynamic>?) ??
        (json['answers'] as List<dynamic>?) ??
        <dynamic>[];

    return StudentAttemptResult(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      wrongAnswers: (json['wrongAnswers'] as num?)?.toInt() ?? 0,
      totalMarks: (json['totalMarks'] as num?)?.toInt() ?? 0,
      obtainedMarks: (json['obtainedMarks'] as num?)?.toInt() ?? 0,
      submittedAt: _parseDateTime(json['submittedAt'] as String?),
      questions: rawQuestions
          .map(
            (item) => StudentAttemptQuestionReview.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

DateTime? _parseDateTime(String? input) {
  if (input == null || input.isEmpty) return null;
  return DateTime.tryParse(input);
}
