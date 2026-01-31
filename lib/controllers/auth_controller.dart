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

  Future<void> saveToken(String token) async {
    await _authService.saveToken(token);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _authService.saveUser(user);
  }
}
