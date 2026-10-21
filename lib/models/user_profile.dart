class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
  });

  final String id;
  final String name;
  final String email;
  final String? mobile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    mobile: json['mobile'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
  };
}
