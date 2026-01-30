import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:money/utils/app_urls.dart';

class AuthService {
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
        return 'Signup failed: ${response.statusCode} - $responseBody';
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
        return 'Resend OTP failed: ${response.statusCode} - ${response.body}';
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
        return 'Verify OTP failed: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Verify OTP error: ${e.toString()}';
    }
  }
}
