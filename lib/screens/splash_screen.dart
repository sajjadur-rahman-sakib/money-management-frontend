import 'package:flutter/material.dart';
import 'package:cashflow/services/auth_service.dart';
import 'package:cashflow/screens/login_screen.dart';
import 'package:cashflow/screens/book_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final authService = AuthService();
    final token = await authService.getToken();
    final user = await authService.getUser();

    if (!mounted) return;

    if (token != null && token.isNotEmpty && user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookScreen(user: user)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
