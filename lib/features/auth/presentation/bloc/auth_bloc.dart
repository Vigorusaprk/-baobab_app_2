import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/check_auth_status_use_case.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/login_usecase.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/logout_usecase.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/signup_usecase.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_event.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<SignUpSubmittedEvent>(_onSignUpSubmitted);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await checkAuthStatusUseCase();
      if (user != null) {
        emit(AuthenticatedState(user: user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await loginUseCase(event.email, event.password);
      emit(AuthenticatedState(user: user));
    } catch (e) {
      emit(AuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> _onSignUpSubmitted(SignUpSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await signUpUseCase(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
      );
      emit(AuthenticatedState(user: user));
    } catch (e) {
      emit(AuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      await logoutUseCase();
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthFailureState(errorMessage: e.toString()));
    }
  }
}