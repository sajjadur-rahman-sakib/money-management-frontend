import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:money/services/auth_service.dart';
import 'package:money/utils/app_urls.dart';
import 'package:money/utils/error_parser.dart';

class ProfileService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getProfile() async {
    String? token = await _authService.getToken();
    var response = await http.get(
      AppUrls.uri(AppUrls.profile),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(
      parseErrorMessage(
        response.body,
        fallback: 'Unable to load profile. Please try again.',
      ),
    );
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    File? picture,
  }) async {
    String? token = await _authService.getToken();
    var request = http.MultipartRequest(
      'POST',
      AppUrls.uri(AppUrls.updateProfile),
    );
    request.headers['Authorization'] = 'Bearer $token';

    if (name != null && name.isNotEmpty) {
      request.fields['name'] = name;
    }
    if (picture != null) {
      request.files.add(
        await http.MultipartFile.fromPath('picture', picture.path),
      );
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    }
    throw Exception(
      parseErrorMessage(
        responseBody,
        fallback: 'Unable to update profile. Please try again.',
      ),
    );
  }
}
