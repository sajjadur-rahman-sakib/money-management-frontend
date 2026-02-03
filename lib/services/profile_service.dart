import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money/services/auth_service.dart';
import 'package:money/utils/app_urls.dart';

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
      'Failed to load profile: ${response.statusCode} - ${response.body}',
    );
  }
}
