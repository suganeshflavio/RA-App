class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    this.className,
  });

  final String id;
  final String name;
  final String email;
  final String? mobile;

  /// The student's grade/standard (e.g. "10th", "12th", "NEET"), set at
  /// registration. Used to auto-resolve which Class node to drill into
  /// under a Subject, without asking the student to pick one.
  final String? className;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    mobile: json['mobile'] as String?,
    className: json['class'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'class': className,
  };
}
