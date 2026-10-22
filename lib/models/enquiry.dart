class EnquiryRequest {
  const EnquiryRequest({
    required this.name,
    required this.email,
    required this.category,
    required this.message,
  });

  final String name;
  final String email;
  final String category;
  final String message;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'category': category,
    'message': message,
  };
}
