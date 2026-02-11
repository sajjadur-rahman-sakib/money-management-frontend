import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/controllers/profile_controller.dart';
import 'package:money/services/auth_service.dart';
import 'package:money/utils/error_parser.dart';

abstract class ProfileEvent {}

class FetchProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? name;
  final File? picture;

  UpdateProfileEvent({this.name, this.picture});
}

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;
  ProfileLoaded(this.profile);
}

class ProfileUpdated extends ProfileState {
  final Map<String, dynamic> profile;
  ProfileUpdated(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileUpdateError extends ProfileState {
  final String message;
  ProfileUpdateError(this.message);
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileController _controller = ProfileController();
  final AuthService _authService = AuthService();

  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        var profile = await _controller.fetchProfile();
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(parseExceptionMessage(e)));
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileUpdating());
      try {
        var profile = await _controller.updateProfile(
          name: event.name,
          picture: event.picture,
        );
        await _authService.saveUser(profile);
        emit(ProfileUpdated(profile));
      } catch (e) {
        emit(ProfileUpdateError(parseExceptionMessage(e)));
      }
    });
  }
}
