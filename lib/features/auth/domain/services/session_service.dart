abstract class SessionService {
  bool isSessionValid(DateTime loginTime);
  Duration getSessionDuration();
}

// File: features/auth/domain/services/session_service_impl.dart
class SessionServiceImpl implements SessionService {
  static const Duration _sessionDuration = Duration(hours: 2);

  @override
  bool isSessionValid(DateTime loginTime) {
    final expiryTime = loginTime.add(_sessionDuration);
    return DateTime.now().isBefore(expiryTime);
  }

  @override
  Duration getSessionDuration() => _sessionDuration;
}
