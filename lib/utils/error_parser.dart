import 'dart:convert';

String parseErrorMessage(
  String body, {
  String fallback = 'Something went wrong',
}) {
  if (body.trim().isEmpty) return fallback;
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'] ?? decoded['message'];
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }
    }
  } catch (_) {
    // Ignore JSON parsing errors.
  }
  return body;
}
