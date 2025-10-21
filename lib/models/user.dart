class User {
  final String id;
  final String firstName;
  final String lastName;
  final String dniNumber;
  final String email;
  final bool approved;
  final String role;
  final bool active;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dniNumber,
    required this.email,
    required this.approved,
    required this.role,
    required this.active,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dniNumber: json['dniNumber'] ?? '',
      email: json['email'] ?? '',
      approved: json['approved'] ?? false,
      role: json['role'] ?? 'user',
      active: json['active'] ?? true,
    );
  }
}
