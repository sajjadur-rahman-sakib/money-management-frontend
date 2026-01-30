import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? picture;
  final String? otp;
  final DateTime? otpExpiry;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.picture,
    this.otp,
    this.otpExpiry,
    this.isActive = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? Uuid().v4(),
      name: json['name'],
      email: json['email'],
      password: json['password'],
      picture: json['picture'],
      otp: json['otp'],
      otpExpiry: json['otp_expiry'] != null
          ? DateTime.parse(json['otp_expiry'])
          : null,
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'picture': picture,
      'otp': otp,
      'otp_expiry': otpExpiry?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
