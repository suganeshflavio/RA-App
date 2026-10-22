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

/// What kind of content a course actually grants, used to route the
/// student straight to the right screen instead of a one-size-fits-all
/// Subject/Chapter/Topic drill-down.
enum CourseCategory {
  /// Has at least one granted video — the full Subject/Chapter/Topic flow.
  video,

  /// No videos, but has granted notes — flat "Notes (eBook)" list.
  notes,

  /// No videos, but has granted MCQ tests — flat "MCQ Test" list.
  test,

  /// No video, but both notes and MCQ tests are granted — show both flat
  /// sections rather than picking one arbitrarily.
  mixed,

  /// Nothing granted yet (shouldn't normally happen for an enrolled course).
  empty,
}

class UserAccessVideo {
  const UserAccessVideo({required this.videoId, required this.videoName});

  final String videoId;
  final String videoName;

  factory UserAccessVideo.fromJson(Map<String, dynamic> json) =>
      UserAccessVideo(
        videoId: json['videoId'] as String? ?? '',
        videoName: json['videoName'] as String? ?? '',
      );
}

class UserAccessNotes {
  const UserAccessNotes({required this.notesId, required this.title});

  final String notesId;
  final String title;

  factory UserAccessNotes.fromJson(Map<String, dynamic> json) =>
      UserAccessNotes(
        notesId: json['notesId'] as String? ?? '',
        title: json['title'] as String? ?? '',
      );
}

class UserAccessMcqTest {
  const UserAccessMcqTest({required this.testId, required this.testName});

  final String testId;
  final String testName;

  factory UserAccessMcqTest.fromJson(Map<String, dynamic> json) =>
      UserAccessMcqTest(
        testId: json['testId'] as String? ?? '',
        testName: json['testName'] as String? ?? '',
      );
}

class UserCourse {
  const UserCourse({
    required this.courseId,
    required this.courseName,
    required this.videos,
    required this.notes,
    required this.mcqTests,
  });

  final String courseId;
  final String courseName;
  final List<UserAccessVideo> videos;
  final List<UserAccessNotes> notes;
  final List<UserAccessMcqTest> mcqTests;

  CourseCategory get category {
    if (videos.isNotEmpty) return CourseCategory.video;
    if (notes.isNotEmpty && mcqTests.isNotEmpty) return CourseCategory.mixed;
    if (notes.isNotEmpty) return CourseCategory.notes;
    if (mcqTests.isNotEmpty) return CourseCategory.test;
    return CourseCategory.empty;
  }

  /// Ids of the videos/notes/tests granted for this course — used to filter
  /// a Topic's catalog content down to only what this student can see.
  Set<String> get grantedVideoIds => videos.map((v) => v.videoId).toSet();
  Set<String> get grantedNotesIds => notes.map((n) => n.notesId).toSet();
  Set<String> get grantedTestIds => mcqTests.map((t) => t.testId).toSet();

  factory UserCourse.fromJson(Map<String, dynamic> json) => UserCourse(
    courseId: json['courseId'] as String,
    courseName: json['courseName'] as String,
    videos: (json['videos'] as List<dynamic>? ?? [])
        .map((e) => UserAccessVideo.fromJson(e as Map<String, dynamic>))
        .toList(),
    notes: (json['notes'] as List<dynamic>? ?? [])
        .map((e) => UserAccessNotes.fromJson(e as Map<String, dynamic>))
        .toList(),
    mcqTests: (json['mcqTests'] as List<dynamic>? ?? [])
        .map((e) => UserAccessMcqTest.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
