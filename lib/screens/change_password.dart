import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/bloc/auth_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildShadowField(
                  controller: _currentController,
                  hint: 'Current Password',
                  isPassword: true,
                  obscureText: _obscureCurrent,
                  toggleVisibility: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter current password' : null,
                ),
                const SizedBox(height: 20),
                _buildShadowField(
                  controller: _newController,
                  hint: 'New Password',
                  isPassword: true,
                  obscureText: _obscureNew,
                  toggleVisibility: () =>
                      setState(() => _obscureNew = !_obscureNew),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter new password' : null,
                ),
                const SizedBox(height: 20),
                _buildShadowField(
                  controller: _confirmController,
                  hint: 'Confirm Password',
                  isPassword: true,
                  obscureText: _obscureConfirm,
                  toggleVisibility: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (value) =>
                      value!.isEmpty ? 'Confirm new password' : null,
                ),
                const SizedBox(height: 60),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9DB2CE),
                          foregroundColor: const Color(0xFF1E2D4A),
                          shape: const StadiumBorder(),
                          elevation: 10,
                          shadowColor: Colors.black26,
                        ),
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                        ChangePasswordEvent(
                                          _currentController.text,
                                          _newController.text,
                                          _confirmController.text,
                                        ),
                                      );
                                }
                              },
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Update Password',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShadowField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? toggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.black26,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}
