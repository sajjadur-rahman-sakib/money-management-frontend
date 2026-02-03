import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:money/utils/app_urls.dart';
import 'package:money/utils/error_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user);
    await prefs.setString('user', userJson);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  Future<bool> verifyToken() async {
    String? token = await getToken();
    if (token == null) return false;
    var response = await http.get(
      AppUrls.uri('/verify-token'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<String?> signup(
    String name,
    String email,
    String password,
    File picture,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppUrls.resolve(AppUrls.signup)),
      );

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.files.add(
        await http.MultipartFile.fromPath('picture', picture.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return null;
      } else {
        return parseErrorMessage(responseBody, fallback: 'Signup failed');
      }
    } catch (e) {
      return 'Signup error: ${e.toString()}';
    }
  }

  Future<String?> resendOtp(String email) async {
    try {
      var response = await http.post(
        AppUrls.uri(AppUrls.resendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return parseErrorMessage(response.body, fallback: 'Resend OTP failed');
      }
    } catch (e) {
      return 'Resend OTP error: ${e.toString()}';
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    try {
      var response = await http.post(
        AppUrls.uri(AppUrls.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      if (response.statusCode == 200) {
        return null;
      } else {
        return parseErrorMessage(response.body, fallback: 'Verify OTP failed');
      }
    } catch (e) {
      return 'Verify OTP error: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      var response = await http.post(
        AppUrls.uri(AppUrls.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      String? token = await getToken();
      var response = await http.post(
        AppUrls.uri(AppUrls.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return parseErrorMessage(
          response.body,
          fallback: 'Change password failed',
        );
      }
    } catch (e) {
      return 'Change password error: ${e.toString()}';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
