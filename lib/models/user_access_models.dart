import 'user_profile.dart';

class UserAccessResponse {
  const UserAccessResponse({required this.success, required this.data});

  final bool success;
  final UserAccessData data;

  factory UserAccessResponse.fromJson(Map<String, dynamic> json) =>
      UserAccessResponse(
        success: json['success'] as bool,
        data: UserAccessData.fromJson(json['data'] as Map<String, dynamic>),
      );
}

class UserAccessData {
  const UserAccessData({required this.user, required this.courses});

  final UserProfile user;
  final List<UserCourse> courses;

  factory UserAccessData.fromJson(Map<String, dynamic> json) =>
      UserAccessData(
        user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
        courses: (json['courses'] as List<dynamic>)
            .map((e) => UserCourse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class UserCourse {
  const UserCourse({
    required this.courseId,
    required this.courseName,
    required this.subjects,
  });

  final String courseId;
  final String courseName;
  final List<UserSubject> subjects;

  int get chapterCount =>
      subjects.fold(0, (sum, subject) => sum + subject.chapters.length);

  factory UserCourse.fromJson(Map<String, dynamic> json) => UserCourse(
    courseId: json['courseId'] as String,
    courseName: json['courseName'] as String,
    subjects: (json['subjects'] as List<dynamic>)
        .map((e) => UserSubject.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class UserSubject {
  const UserSubject({required this.subject, required this.chapters});

  final String subject;
  final List<String> chapters;

  factory UserSubject.fromJson(Map<String, dynamic> json) => UserSubject(
    subject: json['subject'] as String,
    chapters: (json['chapters'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
  );
}
