class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool? hasCompany;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'founder',
    this.hasCompany,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'founder',
      hasCompany: json['hasCompany'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    if (hasCompany != null) 'hasCompany': hasCompany,
    if (createdAt != null) 'created_at': createdAt,
  };
}