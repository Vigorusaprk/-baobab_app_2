part of 'auth_bloc.dart';

abstract class AuthEvent {}

class RequestEmailOtpEvent extends AuthEvent {
  RequestEmailOtpEvent({required this.email});

  final String email;
}

class VerifyEmailOtpEvent extends AuthEvent {
  VerifyEmailOtpEvent({required this.email, required this.code});

  final String email;
  final String code;
}

class AuthWithGoogleEvent extends AuthEvent {}

class AuthWithAppleEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}
