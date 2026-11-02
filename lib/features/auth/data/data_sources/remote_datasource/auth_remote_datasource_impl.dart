import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_apple_datasource.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_google_datasource.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_otp_datasource.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';

/// Authentification Supabase : mot de passe, déconnexion, et les
/// capacités spécialisées (e-mail + code, Google, Apple).
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this.supabaseClient)
    : _google = AuthGoogleDataSource(supabaseClient),
      _apple = AuthAppleDataSource(supabaseClient),
      _otp = AuthOtpDataSource(supabaseClient);

  final SupabaseClient supabaseClient;
  final AuthGoogleDataSource _google;
  final AuthAppleDataSource _apple;
  final AuthOtpDataSource _otp;

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }

  @override
  Future<void> setPassword(String password) async {
    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(password: password, data: {'password_set': true}),
      );
    } on AuthWeakPasswordException {
      throw AuthException(
        'Le mot de passe est trop faible. Choisissez-en un d\'au moins 10 caractères comportant une lettre et un chiffre.',
      );
    } on AuthException catch (e) {
      final message = e.code == 'same_password'
          ? 'Le nouveau mot de passe doit être différent de l\'ancien.'
          : e.code == 'session_expired'
          ? 'Votre session a expiré. Reconnectez-vous puis réessayez de définir le mot de passe.'
          : 'La définition du mot de passe a échoué. Vérifiez votre connexion puis réessayez.';
      throw AuthException(message);
    } catch (e) {
      throw AuthException(
        'Pas de connexion. Vérifiez votre réseau et réessayez.',
      );
    }
  }

  @override
  Future<bool> hasPassword() async {
    final user = supabaseClient.auth.currentUser;
    // Convention : un utilisateur « a un mot de passe » dès lors que son
    // userMetadata Supabase porte la clé `password_set`, posée par SetPassword.
    // Un compte OAuth pur n'a jamais cette clé.
    return user?.userMetadata?['password_set'] == true;
  }

  @override
  Future<void> requestEmailOtp(String email) => _otp.requestEmailOtp(email);

  @override
  Future<void> verifyEmailOtp(String email, String code) =>
      _otp.verifyEmailOtp(email, code);

  @override
  Future<void> authWithApple() => _apple.authWithApple();

  @override
  Future<Either<Failure, AuthResponse>> authWithGoogle() =>
      _google.authWithGoogle();
}
