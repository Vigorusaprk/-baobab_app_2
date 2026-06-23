abstract class AuthEvent {
  const AuthEvent();
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent({required this.email, required this.password});
}

class SignUpSubmittedEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? phone;

  const SignUpSubmittedEvent({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });
}

class LogoutRequestedEvent extends AuthEvent {}