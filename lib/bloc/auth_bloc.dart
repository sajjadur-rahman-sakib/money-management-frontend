import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/controllers/auth_controller.dart';
import 'package:money/models/user_model.dart';

abstract class AuthEvent {}

class SignupEvent extends AuthEvent {
  final String name, email, password;
  final File picture;
  SignupEvent(this.name, this.email, this.password, this.picture);
}

class ResendOtpEvent extends AuthEvent {
  final String email;
  ResendOtpEvent(this.email);
}

class VerifyOtpEvent extends AuthEvent {
  final String email, otp;
  VerifyOtpEvent(this.email, this.otp);
}

class LoginEvent extends AuthEvent {
  final String email, password;
  LoginEvent(this.email, this.password);
}

class ChangePasswordEvent extends AuthEvent {
  final String currentPassword, newPassword, confirmPassword;
  ChangePasswordEvent(
    this.currentPassword,
    this.newPassword,
    this.confirmPassword,
  );
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SignupSuccess extends AuthState {}

class OtpSent extends AuthState {}

class OtpVerified extends AuthState {
  final User user;
  OtpVerified(this.user);
}

class LoginSuccess extends AuthState {
  final Map<String, dynamic> user;
  LoginSuccess(this.user);
}

class ChangePasswordSuccess extends AuthState {
  final String message;
  ChangePasswordSuccess(this.message);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthController _authController = AuthController();

  AuthBloc() : super(AuthInitial()) {
    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        String? error = await _authController.signup(
          event.name,
          event.email,
          event.password,
          event.picture,
        );
        if (error == null) {
          emit(SignupSuccess());
        } else {
          emit(AuthError(error));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ResendOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        String? error = await _authController.resendOtp(event.email);
        if (error == null) {
          emit(OtpSent());
        } else {
          emit(AuthError(error));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        String? error = await _authController.verifyOtp(event.email, event.otp);
        if (error == null) {
          emit(
            OtpVerified(
              User(
                id: '',
                name: '',
                email: event.email,
                password: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ),
          );
        } else {
          emit(AuthError(error));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        var user = await _authController.login(event.email, event.password);
        if (user != null && user['token'] != null) {
          // Save the token for future requests
          await _authController.saveToken(user['token']);
          // Save user data without token
          var userData = Map<String, dynamic>.from(user)..remove('token');
          await _authController.saveUser(userData);
          emit(LoginSuccess(user));
        } else {
          emit(
            AuthError('Login failed - invalid credentials or missing token'),
          );
        }
      } catch (e) {
        emit(AuthError('Login error: ${e.toString()}'));
      }
    });

    on<ChangePasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        String? error = await _authController.changePassword(
          event.currentPassword,
          event.newPassword,
          event.confirmPassword,
        );
        if (error == null) {
          emit(ChangePasswordSuccess('Password updated'));
        } else {
          emit(AuthError(error));
        }
      } catch (e) {
        emit(AuthError('Change password error: ${e.toString()}'));
      }
    });
  }
}
