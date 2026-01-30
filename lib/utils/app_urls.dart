class AppUrls {
  AppUrls._();

  static const String baseUrl = 'http://10.0.2.2:1234';

  static const String apiPrefix = '';

  static const String signup = '/signup';
  static const String resendOtp = '/resend-otp';
  static const String verifyOtp = '/verify-otp';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');

  static String resolve(String path) => '$baseUrl$path';
}
