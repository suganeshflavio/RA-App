class Comment {
  const Comment({
    required this.id,
    required this.message,
    required this.authorName,
    this.createdAt,
    this.replies = const [],
  });

  final String id;
  final String message;
  final String authorName;
  final DateTime? createdAt;
  final List<Comment> replies;

  factory Comment.fromJson(Map<String, dynamic> json) {
    final userJson =
        json['user'] as Map<String, dynamic>? ??
        json['author'] as Map<String, dynamic>?;
    final authorName =
        (userJson?['name'] as String?) ??
        (json['userName'] as String?) ??
        (json['authorName'] as String?) ??
        'User';
    final repliesJson =
        json['replies'] as List<dynamic>? ??
        json['children'] as List<dynamic>? ??
        const [];

    return Comment(
      id: json['id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      authorName: authorName,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      replies: repliesJson
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
