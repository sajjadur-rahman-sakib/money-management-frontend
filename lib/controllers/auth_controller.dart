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
}
