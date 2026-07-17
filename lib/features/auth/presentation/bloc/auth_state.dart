part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class RequestEmailOtpLoading extends AuthState {}

class RequestEmailOtpSuccess extends AuthState {
  RequestEmailOtpSuccess({required this.email});

  final String email;
}

class RequestEmailOtpFailure extends AuthState {
  RequestEmailOtpFailure({required this.error});

  final String error;
}

class VerifyEmailOtpLoading extends AuthState {}

class VerifyEmailOtpSuccess extends AuthState {}

class VerifyEmailOtpFailure extends AuthState {
  VerifyEmailOtpFailure({required this.error});

  final String error;
}

class AuthWithGoogleLoading extends AuthState {}

class AuthWithGoogleSuccess extends AuthState {}

class AuthWithGoogleFailure extends AuthState {
  AuthWithGoogleFailure({required this.error});

  final String error;
}

class AuthWithAppleLoading extends AuthState {}

class AuthWithAppleSuccess extends AuthState {}

class AuthWithAppleFailure extends AuthState {
  AuthWithAppleFailure({required this.error});

  final String error;
}

class SignOutLoading extends AuthState {}

class SignOutSuccess extends AuthState {}

class SignOutFailure extends AuthState {
  SignOutFailure({required this.error});

  final String error;
}
