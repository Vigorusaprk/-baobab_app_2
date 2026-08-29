import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

import 'package:baobabe_0_2/core/constants/test_account.dart';
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/secrets.dart';
import '../../../../../core/errors/failure.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this.supabaseClient);

  final SupabaseClient supabaseClient;

  @override
  Future<void> requestEmailOtp(String email) async {
    if (email == TestAccount.appleEmailTest ||
        email == TestAccount.googleEmailTest ||
        email == TestAccount.userEmailTest) {
      return;
    }
    await supabaseClient.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  @override
  Future<void> verifyEmailOtp(String email, String code) async {
    if (email == TestAccount.appleEmailTest &&
            code == TestAccount.appleOtpTest ||
        email == TestAccount.googleEmailTest &&
            code == TestAccount.googleOtpTest ||
        email == TestAccount.userEmailTest && code == TestAccount.userOtpTest) {
      await connectionTest(email);
      return;
    }
    await supabaseClient.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
  }

  @override
  Future<void> authWithApple() async {
    final rawNonce = supabaseClient.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
        'Could not find ID Token from generated credential.',
      );
    }
    await supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
    // Apple only provides the user's full name on the first sign-in
    // Save it to user metadata if available
    if (credential.givenName != null || credential.familyName != null) {
      final nameParts = <String>[];
      if (credential.givenName != null) nameParts.add(credential.givenName!);
      if (credential.familyName != null) nameParts.add(credential.familyName!);
      final fullName = nameParts.join(' ');
      await supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'given_name': credential.givenName,
            'family_name': credential.familyName,
          },
        ),
      );
    }
  }

  @override
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

      // Cas non identifié : on journalise le détail, l'utilisateur lit une
      // phrase. Une trace de pile ne lui dit pas quoi faire.
      debugPrint('Connexion Google — échec non identifié : $e');
      return Left(
        AuthFailure(
          message: "La connexion n'a pas abouti. Réessayez dans un instant.",
        ),
      );
    }
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }

  Future<void> connectionTest(String email) async {
    final String password = email == TestAccount.appleEmailTest
        ? TestAccount.appleMpTest
        : email == TestAccount.googleEmailTest
        ? TestAccount.googleMpTest
        : TestAccount.userMpTest;
    try {
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthApiException {
      rethrow;
    } catch (e) {
      throw AuthApiException(e.toString());
    }
  }
}
