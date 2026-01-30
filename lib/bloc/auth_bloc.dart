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

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SignupSuccess extends AuthState {}

class OtpSent extends AuthState {}

class OtpVerified extends AuthState {
  final User user;
  OtpVerified(this.user);
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
  }
}
