import 'package:equatable/equatable.dart';
import 'package:project1/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthPendingApproval extends AuthState {
  final UserModel user;

  AuthPendingApproval(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoggedIn extends AuthState {
  final UserModel user;
  AuthLoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoggedOut extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthApprovalGranted extends AuthState {}

class AuthRejected extends AuthState {
  final String message;
  AuthRejected(this.message);
}
