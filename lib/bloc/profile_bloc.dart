import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/controllers/profile_controller.dart';

abstract class ProfileEvent {}

class FetchProfileEvent extends ProfileEvent {}

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;
  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileController _controller = ProfileController();

  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        var profile = await _controller.fetchProfile();
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
