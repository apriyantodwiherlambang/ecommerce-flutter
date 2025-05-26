import '../../domain/entities/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess(this.message);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthProfileImageUpdated extends AuthState {}

class AuthProfileLoaded extends AuthState {
  final UserEntity user;
  AuthProfileLoaded(this.user);
}
