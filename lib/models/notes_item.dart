class NotesResponse {
  const NotesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final NotesItem? data;

  factory NotesResponse.fromJson(Map<String, dynamic> json) => NotesResponse(
    success: json['success'] as bool? ?? false,
    message: json['message'] as String? ?? 'Unable to load notes.',
    data: json['data'] == null
        ? null
        : NotesItem.fromJson(json['data'] as Map<String, dynamic>),
  );
}

/// Standalone PDF notes. Not tied to a course/video — reached via whichever
/// Topic/Course it's linked to.
class NotesItem {
  const NotesItem({
    required this.id,
    required this.title,
    required this.notesUrl,
    this.description,
  });

  final String id;
  final String title;
  final String notesUrl;
  final String? description;

  factory NotesItem.fromJson(Map<String, dynamic> json) => NotesItem(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? 'Untitled notes',
    notesUrl: json['notesUrl'] as String? ?? '',
    description: json['description'] as String?,
  );
}
