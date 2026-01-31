import 'package:money/services/profile_service.dart';

class ProfileController {
  final ProfileService _profileService = ProfileService();

  Future<Map<String, dynamic>> fetchProfile() async {
    return await _profileService.getProfile();
  }
}
