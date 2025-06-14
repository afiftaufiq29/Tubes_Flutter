class UserModel {
  final String name;
  final String email;
  final String phone;
  final DateTime? joinDate; // Change to DateTime?
  final String password;

  UserModel({
    required this.name,
    required this.email,
    this.phone = '',
    this.joinDate, // Make it nullable as it might be set by backend
    this.password = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'join_date': joinDate?.toIso8601String(), // Send as ISO 8601 string
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? 'User Name',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      joinDate: json['join_date'] != null
          ? DateTime.parse(json['join_date'])
          : null, // Parse from 'join_date'
      password:
          json['password'] ?? '', // Password is typically not returned in JSON
    );
  }
}
