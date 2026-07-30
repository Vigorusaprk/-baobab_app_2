import 'dart:async';

import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthSessionState {
  const AuthSessionState();
}

class AuthSessionAuthenticated extends AuthSessionState {
  const AuthSessionAuthenticated();
}

class AuthSessionUnauthenticated extends AuthSessionState {
  const AuthSessionUnauthenticated();
}

/// Thin presentation-layer adapter: turns [SessionService]'s auth stream
/// (business/data layer) into a UI-facing state so widgets can react via
/// BlocListener/BlocSelector instead of depending on SessionService directly.
class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit() : super(_stateFor(SessionService.instance.isLoggedIn)) {
    _subscription = SessionService.instance.authStateChanges.listen((_) {
      emit(_stateFor(SessionService.instance.isLoggedIn));
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  static AuthSessionState _stateFor(bool isLoggedIn) {
    return isLoggedIn
        ? const AuthSessionAuthenticated()
        : const AuthSessionUnauthenticated();
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
