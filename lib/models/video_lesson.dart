class VideoResponse {
  const VideoResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final VideoLesson? data;

  factory VideoResponse.fromJson(Map<String, dynamic> json) => VideoResponse(
    success: json['success'] as bool? ?? false,
    message: json['message'] as String? ?? 'Unable to load video.',
    data: json['data'] == null
        ? null
        : VideoLesson.fromJson(json['data'] as Map<String, dynamic>),
  );
}

/// A standalone video. No longer tied to one course/subject/chapter —
/// it's reached via whichever Topic(s) it's linked to.
class VideoLesson {
  const VideoLesson({
    required this.id,
    required this.videoName,
    required this.videoUrl,
    required this.description,
    required this.isActive,
    required this.isPreview,
    this.duration,
  });

  final String id;
  final String videoName;
  final String videoUrl;
  final String description;
  final dynamic duration;
  final bool isActive;
  final bool isPreview;

  factory VideoLesson.fromJson(Map<String, dynamic> json) => VideoLesson(
    id: json['id'] as String? ?? '',
    videoName: json['videoName'] as String? ?? 'Untitled video',
    videoUrl: json['videoUrl'] as String? ?? '',
    description: json['description'] as String? ?? '',
    duration: json['duration'],
    isActive: json['isActive'] as bool? ?? true,
    isPreview: json['isPreview'] as bool? ?? false,
  );
}
