import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthSignUpEvent>(_onSignUp);
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password, rememberMe: event.rememberMe);
      emit(AuthAuthenticated(user: user));
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }

  Future<void> _onSignUp(AuthSignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUp(event.name, event.email, event.password);
      emit(AuthAuthenticated(user: user));
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }

  Future<void> _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnAuthenticated());
        }
      } else {
        emit(AuthUnAuthenticated());
      }
    } catch (e) {
      emit(AuthUnAuthenticated());
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnAuthenticated());
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }
}