import 'dart:io';
import 'package:cashflow/services/profile_service.dart';

class ProfileController {
  final ProfileService _profileService = ProfileService();

  Future<Map<String, dynamic>> fetchProfile() async {
    return await _profileService.getProfile();
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    File? picture,
  }) async {
    return await _profileService.updateProfile(name: name, picture: picture);
  }
}
