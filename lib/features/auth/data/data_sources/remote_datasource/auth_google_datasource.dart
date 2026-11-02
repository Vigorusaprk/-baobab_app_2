import 'dart:async';

import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/secrets.dart';

/// Connexion Google : échange du credential OAuth contre une session
/// Supabase, puis gestion des erreurs en français.
class AuthGoogleDataSource {
  AuthGoogleDataSource(this.supabaseClient);

  final SupabaseClient supabaseClient;

  Future<Either<Failure, AuthResponse>> authWithGoogle() async {
    try {
      final scopes = ['email', 'profile'];
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId: Secrets.webIDClient,
        clientId: Secrets.iosIDClient,
      );

      final googleUser = await googleSignIn.authenticate();

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);
      final idToken = googleUser.authentication.idToken;
      final accessToken = authorization.accessToken;
      if (idToken == null) {
        throw 'No Google ID token found.';
      }

      final authResponse = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user == null) {
        return Left(
          AuthFailure(
            message: "La connexion Google n'a pas abouti. Réessayez.",
          ),
        );
      }

      final supabaseUser = authResponse.user!;
      if (supabaseUser.email == null || supabaseUser.email!.isEmpty) {
        return Left(
          AuthFailure(
            message:
                'Votre compte Google ne partage pas son adresse e-mail. '
                'Autorisez-la, ou connectez-vous par e-mail.',
          ),
        );
      }

      return Right(authResponse);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on TimeoutException {
      return Left(
        AuthFailure(
          message:
              'La connexion Google a mis trop de temps. Vérifiez votre '
              'réseau et réessayez.',
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('cancel') ||
          errorMessage.contains('user_cancel')) {
        return Left(AuthFailure(message: 'Connexion annulée.'));
      }
      if (errorMessage.contains('network')) {
        return Left(
          AuthFailure(
            message: 'Pas de connexion. Vérifiez votre réseau, puis réessayez.',
          ),
        );
      }

      debugPrint('Connexion Google — échec non identifié : $e');
      return Left(
        AuthFailure(
          message: "La connexion n'a pas abouti. Réessayez dans un instant.",
        ),
      );
    }
  }
}
