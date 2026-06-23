import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final UserEntity user;
  const AuthenticatedState({required this.user});
}

class UnauthenticatedState extends AuthState {}

class AuthFailureState extends AuthState {
  final String errorMessage;
  const AuthFailureState({required this.errorMessage});
}