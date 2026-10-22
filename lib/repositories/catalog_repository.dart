import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/catalog_models.dart';

/// Read-only access to the Subject -> Class -> Chapter -> Topic content
/// hierarchy. Used to drill down into a "video" category course.
class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;

  List<dynamic> _listFrom(dynamic body, String key) {
    if (body is! Map<String, dynamic>) return const [];
    final data = body['data'];
    if (data is! Map<String, dynamic>) return const [];
    final list = data[key];
    return list is List<dynamic> ? list : const [];
  }

  Map<String, dynamic>? _dataOf(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final data = body['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  Future<List<SubjectItem>> fetchSubjects() async {
    try {
      final response = await _client.get(
        '/api/subjects',
        queryParameters: {'limit': 200},
      );
      return _listFrom(response.data, 'subjects')
          .map((e) => SubjectItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Subjects linked to a specific course, via `GET /api/courses/:id`,
  /// grouped by subject so a subject linked to several classes (a bundled
  /// course) still appears once with all of its class links attached.
  Future<List<CourseSubjectGroup>> fetchCourseSubjects(String courseId) async {
    try {
      final response = await _client.get('/api/courses/$courseId');
      final data = _dataOf(response.data);
      final links = data?['subjects'] as List<dynamic>? ?? const [];

      final order = <String>[];
      final groups = <String, List<CourseSubjectClassLink>>{};
      final names = <String, String>{};

      for (final raw in links) {
        if (raw is! Map<String, dynamic>) continue;
        final subject = raw['subject'];
        if (subject is! Map<String, dynamic>) continue;
        final subjectId = subject['id'] as String? ?? '';
        if (subjectId.isEmpty) continue;

        final classMap = raw['class'];
        final classLink = classMap is Map<String, dynamic>
            ? CourseSubjectClassLink(
                classId: classMap['id'] as String?,
                className: classMap['name'] as String?,
              )
            : const CourseSubjectClassLink();

        if (!groups.containsKey(subjectId)) {
          order.add(subjectId);
          groups[subjectId] = [];
          names[subjectId] = subject['name'] as String? ?? '';
        }
        groups[subjectId]!.add(classLink);
      }

      return order
          .map(
            (subjectId) => CourseSubjectGroup(
              subjectId: subjectId,
              subjectName: names[subjectId] ?? '',
              classLinks: groups[subjectId]!,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Topics linked to a specific course (`CourseTopic`), via
  /// `GET /api/courses/:id`. This is the primary source of a course's
  /// browsable Subject/Class/Chapter/Topic tree — [fetchCourseSubjects] is
  /// now a legacy fallback for courses that predate topic-level linking.
  Future<List<CourseTopicRef>> fetchCourseTopics(String courseId) async {
    try {
      final response = await _client.get('/api/courses/$courseId');
      final data = _dataOf(response.data);
      final links = data?['topics'] as List<dynamic>? ?? const [];

      final refs = <CourseTopicRef>[];
      for (final raw in links) {
        if (raw is! Map<String, dynamic>) continue;
        final topic = raw['topic'];
        if (topic is! Map<String, dynamic>) continue;
        final chapter = topic['chapter'];
        if (chapter is! Map<String, dynamic>) continue;
        final klass = chapter['class'];
        if (klass is! Map<String, dynamic>) continue;
        final subject = klass['subject'];
        if (subject is! Map<String, dynamic>) continue;

        final topicId = topic['id'] as String? ?? '';
        if (topicId.isEmpty) continue;

        refs.add(
          CourseTopicRef(
            topicId: topicId,
            topicName: topic['name'] as String? ?? '',
            chapterId: chapter['id'] as String? ?? '',
            chapterName: chapter['name'] as String? ?? '',
            classId: klass['id'] as String? ?? '',
            className: klass['name'] as String? ?? '',
            subjectId: subject['id'] as String? ?? '',
            subjectName: subject['name'] as String? ?? '',
          ),
        );
      }

      return refs;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<ClassItem>> fetchClasses(String subjectId) async {
    try {
      final response = await _client.get(
        '/api/classes',
        queryParameters: {'subjectId': subjectId, 'limit': 200},
      );
      return _listFrom(response.data, 'classes')
          .map((e) => ClassItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<ChapterItem>> fetchChapters(String classId) async {
    try {
      final response = await _client.get(
        '/api/chapters',
        queryParameters: {'classId': classId, 'limit': 200},
      );
      return _listFrom(response.data, 'chapters')
          .map((e) => ChapterItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<TopicItem>> fetchTopics(String chapterId) async {
    try {
      final response = await _client.get(
        '/api/topics',
        queryParameters: {'chapterId': chapterId, 'limit': 200},
      );
      final topics = _listFrom(response.data, 'topics')
          .map((e) => TopicItem.fromJson(e as Map<String, dynamic>))
          .toList();
      topics.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
      return topics;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<TopicDetail> fetchTopicById(String topicId) async {
    try {
      final response = await _client.get('/api/topics/$topicId');
      final data = _dataOf(response.data);
      if (data == null) {
        throw ApiException('Unable to load topic.');
      }
      return TopicDetail.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
