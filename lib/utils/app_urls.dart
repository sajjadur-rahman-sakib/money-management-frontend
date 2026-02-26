class AppUrls {
  AppUrls._();

  static const String baseUrl = 'http://54.169.237.118:8080';

  static const String apiPrefix = '';

  static const String signup = '/user-signup';
  static const String resendOtp = '/resend-otp';
  static const String verifyOtp = '/verify-otp';
  static const String login = '/user-login';
  static const String forgotPassword = '/forgot-password';
  static const String verifyForgotPasswordOtp = '/forgot-otp';
  static const String resetPassword = '/reset-password';
  static const String createBook = '/create-book';
  static const String getBooks = '/get-books';
  static const String updateBook = '/update-book';
  static const String deleteBook = '/delete-book';
  static const String createTransaction = '/create-transaction';
  static const String bookDetails = '/book-details';
  static const String updateTransaction = '/update-transaction';
  static const String deleteTransaction = '/delete-transaction';
  static const String profile = '/user-profile';
  static const String updateProfile = '/update-profile';
  static const String changePassword = '/change-password';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');

  static String resolve(String path) => '$baseUrl$path';
}
