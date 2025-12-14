import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/models/user_model.dart';
import 'package:project1/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(AuthInitial());

  void updateUser(UserModel user) {
    emit(AuthLoggedIn(user));
  }

  Future register({
    required String firstName,
    required String lastName,
    required String phone,
    required DateTime birthDate,
    required File profileImage,
    required File idImage,
    required String password,
    required bool isTenant,
  }) async {
    emit(AuthLoading());

    try {
      final user = await repository.registerUser(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        birthDate: birthDate,
        profileImagePath: profileImage.path,
        idImagePath: idImage.path,
        password: password,
        isTenant: isTenant,
      );

      // After registration, user is always pending approval
      emit(AuthPendingApproval(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({required String phone, required String password}) async {
    emit(AuthLoading());

    try {
      final user = await repository.login(phone, password);

      if (user.isCancelled) {
        repository.logout();
        emit(
          AuthRejected("Your account has been rejected by the administration."),
        );
        return;
      }

      if (user.isPending) {
        emit(AuthPendingApproval(user));
        return;
      }

      emit(AuthLoggedIn(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkStatus() async {
    emit(AuthLoading());
    try {
      final user = await repository.getCurrentUser();
      if (user.isCancelled) {
        emit(
          AuthRejected("Your account has been rejected by the administration."),
        );
        return;
      } else if (user.isApproved) {
        // User approved - logout and redirect to login page
        // This allows them to log in fresh with their approved account
        repository.logout();
        emit(AuthLoggedOut());
      } else {
        // Still pending approval
        emit(AuthPendingApproval(user));
      }
    } catch (e) {
      // If error contains rejection message, emit AuthRejected
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains("rejected") || errorMsg.contains("denied")) {
        // Clear token on rejection
        repository.logout();
        emit(AuthRejected("Your registration request has been denied."));
      } else {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
