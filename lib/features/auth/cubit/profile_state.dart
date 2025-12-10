part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdated extends ProfileState {
  final UserModel user;
  ProfileUpdated(this.user);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
