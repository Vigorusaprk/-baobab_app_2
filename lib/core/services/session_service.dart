import 'package:baobabe_0_2/core/constants/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lightweight snapshot of the currently authenticated Supabase user.
///
/// This is intentionally separate from the auth feature's own domain
/// entities: the auth flow (OTP + social sign-in) never populates a
/// business UserEntity, so the rest of the app reads session identity
/// straight from Supabase instead of depending on auth-internal types.
class AppSessionUser {
  const AppSessionUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory AppSessionUser.fromSupabase(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final name =
        (metadata['full_name'] as String?) ??
        (metadata['name'] as String?) ??
        user.email?.split('@').first ??
        'Utilisateur';
    return AppSessionUser(id: user.id, name: name, email: user.email ?? '');
  }
}

/// Single source of truth for "is someone logged in / who are they",
/// read directly from Supabase so no part of the app needs to depend on
/// AuthBloc's granular per-action states to know the session status.
class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  SupabaseClient get _client => SupabaseClientWrapper.client;

  AppSessionUser? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : AppSessionUser.fromSupabase(user);
  }

  bool get isLoggedIn => _client.auth.currentUser != null;

  /// Emits the current session user every time Supabase's auth state changes
  /// (sign in, sign out, token refresh).
  Stream<AppSessionUser?> get userChanges => _client.auth.onAuthStateChange
      .map((data) => data.session?.user)
      .map((user) => user == null ? null : AppSessionUser.fromSupabase(user));

  /// Raw auth state change stream, handy for GoRouter's refreshListenable.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
