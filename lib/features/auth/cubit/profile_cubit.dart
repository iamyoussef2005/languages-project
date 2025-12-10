import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/models/user_model.dart';
import 'package:project1/data/repositories/auth_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository repository;

  ProfileCubit(this.repository) : super(ProfileInitial());

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    File? personalPhoto,
    File? idPhoto,
  }) async {
    emit(ProfileLoading());

    try {
      final user = await repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        personalPhoto: personalPhoto,
        idPhoto: idPhoto,
      );

      emit(ProfileUpdated(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
