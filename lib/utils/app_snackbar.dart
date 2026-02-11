import 'package:flutter/material.dart';

class AppSnackbar {
  static AppSnackbar? _instance;
  static AppSnackbar get instance => _instance ??= AppSnackbar._();

  AppSnackbar._();

  String? _lastMessage;
  DateTime? _lastShownTime;
  static const _duplicateThreshold = Duration(seconds: 2);

  static void showError(BuildContext context, String message) {
    instance._show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFFD32F2F),
      foregroundColor: Colors.white,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    instance._show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
    );
  }

  static void showInfo(BuildContext context, String message) {
    instance._show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: const Color(0xFF1976D2),
      foregroundColor: Colors.white,
    );
  }

  static void showWarning(BuildContext context, String message) {
    instance._show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFFF57C00),
      foregroundColor: Colors.white,
    );
  }

  void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShownTime != null &&
        now.difference(_lastShownTime!) < _duplicateThreshold) {
      return;
    }

    _lastMessage = message;
    _lastShownTime = now;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
        action: SnackBarAction(
          label: 'DISMISS',
          // ignore: deprecated_member_use
          textColor: foregroundColor.withOpacity(0.8),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void clearCache() {
    instance._lastMessage = null;
    instance._lastShownTime = null;
  }
}
