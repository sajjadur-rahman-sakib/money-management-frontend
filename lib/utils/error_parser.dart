import 'dart:convert';

class ErrorCodes {
  static const validation = 'VALIDATION_ERROR';
  static const authentication = 'AUTHENTICATION_ERROR';
  static const notFound = 'NOT_FOUND';
  static const conflict = 'CONFLICT';
  static const server = 'SERVER_ERROR';
  static const unauthorized = 'UNAUTHORIZED';
  static const badRequest = 'BAD_REQUEST';
  static const network = 'NETWORK_ERROR';
}

class AppError {
  final String code;
  final String message;

  const AppError({required this.code, required this.message});

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => code.hashCode ^ message.hashCode;
}

String parseErrorMessage(
  String body, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (body.trim().isEmpty) return fallback;
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'] ?? decoded['error'];
      if (message is String && message.trim().isNotEmpty) {
        return _sanitizeErrorMessage(message);
      }
    }
  } catch (_) {}
  return _sanitizeErrorMessage(body.isNotEmpty ? body : fallback);
}

AppError parseError(
  String body, {
  String fallbackMessage = 'Something went wrong. Please try again.',
}) {
  if (body.trim().isEmpty) {
    return AppError(code: ErrorCodes.server, message: fallbackMessage);
  }
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final code = decoded['code'] as String? ?? ErrorCodes.server;
      final message =
          decoded['message'] as String? ??
          decoded['error'] as String? ??
          fallbackMessage;
      return AppError(code: code, message: _sanitizeErrorMessage(message));
    }
  } catch (_) {}
  return AppError(
    code: ErrorCodes.server,
    message: _sanitizeErrorMessage(body.isNotEmpty ? body : fallbackMessage),
  );
}

String parseExceptionMessage(dynamic exception) {
  final message = exception.toString();
  final lowerMsg = message.toLowerCase();

  if (lowerMsg.contains('socketexception') ||
      lowerMsg.contains('connection refused') ||
      lowerMsg.contains('network is unreachable')) {
    return 'Unable to connect to the server. Please check your internet connection.';
  }

  if (lowerMsg.contains('timeout') || lowerMsg.contains('timed out')) {
    return 'The request timed out. Please check your connection and try again.';
  }

  if (lowerMsg.contains('certificate') || lowerMsg.contains('handshake')) {
    return 'Unable to establish a secure connection. Please try again.';
  }

  if (lowerMsg.contains('formatexception')) {
    return 'Received an unexpected response. Please try again.';
  }

  String cleanMessage = message;
  if (cleanMessage.startsWith('Exception:')) {
    cleanMessage = cleanMessage.substring(10).trim();
  }

  return _sanitizeErrorMessage(cleanMessage);
}

String _sanitizeErrorMessage(String message) {
  String sanitized = message;

  final prefixes = ['Exception: ', 'Error: ', 'error: ', 'FormatException: '];

  for (final prefix in prefixes) {
    if (sanitized.startsWith(prefix)) {
      sanitized = sanitized.substring(prefix.length);
    }
  }

  // Capitalize first letter if not already
  if (sanitized.isNotEmpty && sanitized[0].toLowerCase() == sanitized[0]) {
    sanitized = sanitized[0].toUpperCase() + sanitized.substring(1);
  }

  // Ensure message ends with proper punctuation
  if (sanitized.isNotEmpty &&
      !sanitized.endsWith('.') &&
      !sanitized.endsWith('!') &&
      !sanitized.endsWith('?')) {
    sanitized = '$sanitized.';
  }

  return sanitized;
}

class ErrorMessages {
  static const invalidCredentials =
      'Invalid email or password. Please check your credentials and try again.';
  static const sessionExpired =
      'Your session has expired. Please log in again.';
  static const emailAlreadyExists =
      'This email is already registered. Please use a different email or try logging in.';

  static const invalidOtp =
      'The verification code you entered is incorrect. Please check and try again.';
  static const otpExpired =
      'Your verification code has expired. Please request a new one.';
  static const otpSent = 'A verification code has been sent to your email.';

  static const incorrectCurrentPassword =
      'The current password you entered is incorrect. Please try again.';
  static const passwordMismatch =
      "The passwords you entered don't match. Please make sure both passwords are the same.";
  static const passwordUpdateSuccess =
      'Your password has been updated successfully.';

  static const userNotFound =
      "We couldn't find an account with that email. Please check the email or sign up.";
  static const profileUpdateSuccess =
      'Your profile has been updated successfully.';

  static const noConnection =
      'Unable to connect to the server. Please check your internet connection.';
  static const requestTimeout =
      'The request timed out. Please check your connection and try again.';

  static const somethingWentWrong =
      'Something went wrong. Please try again later.';
  static const requiredFields = 'Please fill in all required fields.';
}
