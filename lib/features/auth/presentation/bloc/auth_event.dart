part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe; // ✅ Ajout

  const AuthLoginEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [email, password, rememberMe];
}

class AuthSignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? imgUrl;

  const AuthSignUpEvent({required this.name, required this.email, required this.password, this.imgUrl});

  @override
  List<Object> get props => [name, email, password];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;
  const ForgotPasswordSubmitted(this.email);
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLogoutEvent extends AuthEvent {}