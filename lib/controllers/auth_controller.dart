import 'dart:io';
import 'package:money/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  bool validateSignup(
    String name,
    String email,
    String password,
    File? picture,
  ) {
    if (name.isEmpty || email.isEmpty || password.isEmpty || picture == null) {
      return false;
    }

    return true;
  }

  Future<String?> signup(
    String name,
    String email,
    String password,
    File picture,
  ) async {
    if (!validateSignup(name, email, password, picture)) {
      return 'Validation failed';
    }
    return await _authService.signup(name, email, password, picture);
  }

  Future<String?> resendOtp(String email) async {
    return await _authService.resendOtp(email);
  }

  Future<String?> verifyOtp(String email, String otp) async {
    return await _authService.verifyOtp(email, otp);
  }

  bool validateLogin(String email, String password) {
    if (email.isEmpty || password.isEmpty) return false;
    return true;
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    if (!validateLogin(email, password)) return null;
    return await _authService.login(email, password);
  }

  Future<String?> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return 'All fields are required';
    }
    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }
    return await _authService.changePassword(
      currentPassword,
      newPassword,
      confirmPassword,
    );
  }

  Future<void> saveToken(String token) async {
    await _authService.saveToken(token);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _authService.saveUser(user);
  }

  Future<String?> forgotPassword(String email) async {
    if (email.isEmpty) {
      return 'Email is required';
    }
    return await _authService.forgotPassword(email);
  }

  Future<String?> verifyForgotPasswordOtp(String email, String otp) async {
    if (email.isEmpty || otp.isEmpty) {
      return 'Email and OTP are required';
    }
    return await _authService.forgotOtp(email, otp);
  }

  Future<String?> resetPassword(
    String email,
    String otp,
    String newPassword,
    String confirmPassword,
  ) async {
    if (email.isEmpty || otp.isEmpty || newPassword.isEmpty) {
      return 'All fields are required';
    }
    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }
    return await _authService.resetPassword(email, otp, newPassword);
  }
}
