class DashboardContent {
  const DashboardContent({
    required this.school,
    required this.resources,
    required this.tests,
    required this.progress,
    required this.videos,
    required this.courses,
  });

  final SchoolProfile school;
  final List<ResourceItem> resources;
  final List<TestItem> tests;
  final List<ProgressMetric> progress;
  final List<VideoItem> videos;
  final List<CourseItem> courses;

  factory DashboardContent.fromJson(Map<String, dynamic> json) {
    return DashboardContent(
      school: SchoolProfile.fromJson(json['school'] as Map<String, dynamic>),
      resources: (json['resources'] as List<dynamic>)
          .map((item) => ResourceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      tests: (json['tests'] as List<dynamic>)
          .map((item) => TestItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      progress: (json['progress'] as List<dynamic>)
          .map((item) => ProgressMetric.fromJson(item as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>)
          .map((item) => VideoItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      courses: (json['courses'] as List<dynamic>)
          .map((item) => CourseItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SchoolProfile {
  const SchoolProfile({required this.name, required this.location});

  final String name;
  final String location;

  factory SchoolProfile.fromJson(Map<String, dynamic> json) {
    return SchoolProfile(
      name: json['name'] as String,
      location: json['location'] as String,
    );
  }
}

class ResourceItem {
  const ResourceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String icon;
  final String accent;

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: json['icon'] as String,
      accent: json['accent'] as String,
    );
  }
}

class TestItem {
  const TestItem({
    required this.title,
    required this.subject,
    required this.questionCount,
    required this.duration,
    required this.status,
  });

  final String title;
  final String subject;
  final int questionCount;
  final String duration;
  final String status;

  factory TestItem.fromJson(Map<String, dynamic> json) {
    return TestItem(
      title: json['title'] as String,
      subject: json['subject'] as String,
      questionCount: json['questionCount'] as int,
      duration: json['duration'] as String,
      status: json['status'] as String,
    );
  }
}

class ProgressMetric {
  const ProgressMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final String accent;

  factory ProgressMetric.fromJson(Map<String, dynamic> json) {
    return ProgressMetric(
      label: json['label'] as String,
      value: json['value'] as String,
      detail: json['detail'] as String,
      accent: json['accent'] as String,
    );
  }
}

class VideoItem {
  const VideoItem({
    required this.title,
    required this.subtitle,
    required this.youtubeId,
    required this.duration,
    required this.description,
  });

  final String title;
  final String subtitle;
  final String youtubeId;
  final String duration;
  final String description;

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      youtubeId: json['youtubeId'] as String,
      duration: json['duration'] as String,
      description: json['description'] as String,
    );
  }
}

class CourseItem {
  const CourseItem({
    required this.title,
    required this.price,
    required this.salePrice,
    required this.lessons,
    required this.duration,
    required this.rating,
    required this.reviewCount,
    required this.language,
    required this.mentorName,
    required this.mentorFollowers,
    required this.description,
    required this.youtubeId,
    required this.thumbnailAsset,
    required this.mentorAvatarAsset,
    required this.subjects,
  });

  final String title;
  final double price;
  final double salePrice;
  final int lessons;
  final String duration;
  final double rating;
  final int reviewCount;
  final String language;
  final String mentorName;
  final String mentorFollowers;
  final String description;
  final String youtubeId;
  final String thumbnailAsset;
  final String mentorAvatarAsset;
  final List<SubjectItem> subjects;

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      lessons: json['lessons'] as int,
      duration: json['duration'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      language: json['language'] as String,
      mentorName: json['mentorName'] as String,
      mentorFollowers: json['mentorFollowers'] as String,
      description: json['description'] as String,
      youtubeId: json['youtubeId'] as String,
      thumbnailAsset: json['thumbnailAsset'] as String,
      mentorAvatarAsset: json['mentorAvatarAsset'] as String,
      subjects: (json['subjects'] as List<dynamic>)
          .map((item) => SubjectItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SubjectItem {
  const SubjectItem({
    required this.title,
    required this.description,
    required this.chapters,
  });

  final String title;
  final String description;
  final List<ChapterItem> chapters;

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
      title: json['title'] as String,
      description: json['description'] as String,
      chapters: (json['chapters'] as List<dynamic>)
          .map((item) => ChapterItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChapterItem {
  const ChapterItem({required this.title, required this.topics});

  final String title;
  final List<TopicItem> topics;

  factory ChapterItem.fromJson(Map<String, dynamic> json) {
    return ChapterItem(
      title: json['title'] as String,
      topics: (json['topics'] as List<dynamic>)
          .map((item) => TopicItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TopicItem {
  const TopicItem({
    required this.title,
    required this.duration,
    required this.youtubeId,
    required this.summary,
  });

  final String title;
  final String duration;
  final String youtubeId;
  final String summary;

  factory TopicItem.fromJson(Map<String, dynamic> json) {
    return TopicItem(
      title: json['title'] as String,
      duration: json['duration'] as String,
      youtubeId: json['youtubeId'] as String,
      summary: json['summary'] as String,
    );
  }
}
