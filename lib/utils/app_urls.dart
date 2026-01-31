class AppUrls {
  AppUrls._();

  static const String baseUrl = 'http://10.0.2.2:1234';

  static const String apiPrefix = '';

  static const String signup = '/user-signup';
  static const String resendOtp = '/resend-otp';
  static const String verifyOtp = '/verify-otp';
  static const String login = '/user-login';
  static const String createBook = '/create-book';
  static const String getBooks = '/get-books';
  static const String createTransaction = '/create-transaction';
  static const String bookDetails = '/book-details';
  static const String profile = '/profile';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');

  static String resolve(String path) => '$baseUrl$path';
}
