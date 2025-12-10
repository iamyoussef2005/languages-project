import 'dart:io';

import 'package:project1/data/models/user_model.dart';
import 'package:project1/data/services/auth_service.dart';

class AuthRepository {
  final AuthService service;

  AuthRepository(this.service);

  Future<UserModel> login(String phone, String password) async {
    final Map<String, dynamic> response = await service.login(phone, password);
    // The response contains a "user" key with user data
    if (response.containsKey("user")) {
      return UserModel.fromJson(response["user"]);
    }
    // Fallback: if response is the user object directly
    return UserModel.fromJson(response);
  }

  Future<UserModel> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
    required DateTime birthDate,
    required String profileImagePath,
    required String idImagePath,
    required String password,
    required bool isTenant,
  }) async {
    final user = await service.registerUser(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      birthDate: birthDate,
      profileImagePath: profileImagePath,
      idImagePath: idImagePath,
      password: password,
      isTenant: isTenant, 
    );
    return user;
  }

  Future<UserModel> getCurrentUser() async {
    return await service.getCurrentUser();
  }

  Future<void> logout() async {
    await service.logout();
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    File? personalPhoto,
    File? idPhoto,
  }) async {
    return await service.updateProfile(
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      personalPhoto: personalPhoto,
      idPhoto: idPhoto,
    );
  }
}
