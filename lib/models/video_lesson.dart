class VideosResponse {
  const VideosResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final VideosData? data;

  factory VideosResponse.fromJson(Map<String, dynamic> json) => VideosResponse(
    success: json['success'] as bool? ?? false,
    message: json['message'] as String? ?? 'Unable to load videos.',
    data: json['data'] == null
        ? null
        : VideosData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

class VideosData {
  const VideosData({
    required this.videos,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<VideoLesson> videos;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  factory VideosData.fromJson(Map<String, dynamic> json) => VideosData(
    videos:
        (json['videos'] as List<dynamic>?)
            ?.map((e) => VideoLesson.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    total: (json['total'] as num?)?.toInt() ?? 0,
    page: (json['page'] as num?)?.toInt() ?? 1,
    limit: (json['limit'] as num?)?.toInt() ?? 0,
    totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
  );
}

class VideoCourseRef {
  const VideoCourseRef({required this.id, required this.courseName});

  final String id;
  final String courseName;

  factory VideoCourseRef.fromJson(Map<String, dynamic> json) => VideoCourseRef(
    id: json['id'] as String? ?? '',
    courseName: json['courseName'] as String? ?? '',
  );
}

class VideoLesson {
  const VideoLesson({
    required this.id,
    required this.courseId,
    required this.subject,
    required this.chapter,
    required this.videoName,
    required this.videoUrl,
    required this.description,
    required this.order,
    required this.isActive,
    required this.isPreview,
    this.duration,
    this.course,
    this.notesUrl,
    this.notesFileName,
  });

  final String id;
  final String courseId;
  final String subject;
  final String chapter;
  final String videoName;
  final String videoUrl;
  final String description;
  final dynamic duration;
  final int order;
  final bool isActive;
  final bool isPreview;
  final VideoCourseRef? course;
  final String? notesUrl;
  final String? notesFileName;

  bool get hasNotes => notesUrl != null && notesUrl!.isNotEmpty;

  String get displayNotesFileName {
    if (notesFileName != null && notesFileName!.isNotEmpty) {
      return notesFileName!;
    }
    if (notesUrl != null && notesUrl!.isNotEmpty) {
      final uri = Uri.tryParse(notesUrl!);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final rawName = uri.pathSegments.last;
        final decoded = Uri.decodeComponent(rawName);
        if (decoded.isNotEmpty) return decoded;
      }
    }
    return '$videoName Notes';
  }

  factory VideoLesson.fromJson(Map<String, dynamic> json) => VideoLesson(
    id: json['id'] as String? ?? '',
    courseId: json['courseId'] as String? ?? '',
    subject: json['subject'] as String? ?? '',
    chapter: json['chapter'] as String? ?? '',
    videoName: json['videoName'] as String? ?? 'Untitled video',
    videoUrl: json['videoUrl'] as String? ?? '',
    description: json['description'] as String? ?? '',
    duration: json['duration'],
    order: (json['order'] as num?)?.toInt() ?? 0,
    isActive: json['isActive'] as bool? ?? true,
    isPreview: json['isPreview'] as bool? ?? false,
    course: json['course'] == null
        ? null
        : VideoCourseRef.fromJson(json['course'] as Map<String, dynamic>),
    notesUrl: json['notesUrl'] as String?,
    notesFileName: json['notesFileName'] as String?,
  );
}
