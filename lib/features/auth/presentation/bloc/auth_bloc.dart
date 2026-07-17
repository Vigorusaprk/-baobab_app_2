import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
       on<RequestEmailOtpEvent>(_requestEmailOtp);
    on<VerifyEmailOtpEvent>(_verifyEmailOtp);
    on<AuthWithGoogleEvent>(_authWithGoogle);
    on<AuthWithAppleEvent>(_authWithApple);
    on<SignOutEvent>(_signOut);
  }

  Future<void> _requestEmailOtp(
    RequestEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(RequestEmailOtpLoading());
    final result = await authRepository.requestEmailOtp(
      event.email,
    );
    result.fold(
      (failure) => emit(RequestEmailOtpFailure(error: failure.message)),
      (_) => emit(RequestEmailOtpSuccess(email: event.email)),
    );
  }

  Future<void> _verifyEmailOtp(
    VerifyEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(VerifyEmailOtpLoading());
    final result = await authRepository.verifyEmailOtp(
      event.email,
      event.code,
    );
    result.fold(
      (failure) => emit(VerifyEmailOtpFailure(error: failure.message)),
      (_) => emit(VerifyEmailOtpSuccess()),
    );
  }

  Future<void> _authWithGoogle(
    AuthWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthWithGoogleLoading());
    final result = await authRepository.authWithGoogle();
    result.fold(
      (failure) => emit(AuthWithGoogleFailure(error: failure.message)),
      (_) => emit(AuthWithGoogleSuccess()),
    );
  }

  Future<void> _authWithApple(
    AuthWithAppleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthWithAppleLoading());
    final result = await authRepository.authWithApple();
    result.fold(
      (failure) => emit(AuthWithAppleFailure(error: failure.message)),
      (_) => emit(AuthWithAppleSuccess()),
    );
  }

  Future<void> _signOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(SignOutLoading());
    final result = await authRepository.signOut();
    result.fold(
      (failure) => emit(SignOutFailure(error: failure.message)),
      (_) => emit(SignOutSuccess()),
    );
  }
}