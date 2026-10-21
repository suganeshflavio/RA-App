class Testimonial {
  const Testimonial({
    required this.star,
    required this.review,
    required this.authorName,
  });

  final int star;
  final String review;
  final String authorName;

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    final userJson =
        json['user'] as Map<String, dynamic>? ??
        json['author'] as Map<String, dynamic>?;
    final authorName =
        (json['username'] as String?) ??
        (userJson?['name'] as String?) ??
        (json['userName'] as String?) ??
        (json['name'] as String?) ??
        (json['authorName'] as String?) ??
        'User';

    return Testimonial(
      star:
          (json['star'] as num?)?.toInt() ??
          (json['rating'] as num?)?.toInt() ??
          5,
      review:
          (json['review'] as String?) ??
          (json['message'] as String?) ??
          (json['text'] as String?) ??
          '',
      authorName: authorName,
    );
  }
}
