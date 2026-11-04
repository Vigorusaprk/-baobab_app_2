import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/set_password_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// La traduction des erreurs de mise à jour de mot de passe.
///
/// Le serveur répond avec des codes GoTrue qui changent selon les versions ;
/// l'interface, elle, ne doit jamais afficher ni une exception brute ni une
/// consigne floue — surtout quand il faut « se reconnecter ».
void main() {
  test('même mot de passe : message dédié', () {
    expect(
      mapSetPasswordError(const AuthApiException('x', code: 'same_password')),
      contains('différent de l\'ancien'),
    );
  });

  test('session expirée : message dédié', () {
    expect(
      mapSetPasswordError(const AuthApiException('x', code: 'session_expired')),
      contains('session a expiré'),
    );
  });

  test('reauthentication_needed : invite à se reconnecter par code e-mail', () {
    expect(
      mapSetPasswordError(
        const AuthApiException(
          'A recent sign in is required',
          statusCode: '403',
          code: 'reauthentication_needed',
        ),
      ),
      contains('code e-mail'),
    );
  });

  test('reauth_nonce_missing : invite aussi à se reconnecter par code e-mail', () {
    expect(
      mapSetPasswordError(
        const AuthApiException('x', statusCode: '403', code: 'reauth_nonce_missing'),
      ),
      contains('code e-mail'),
    );
  });

  test('message serveur "recent" sans code : toujours traduit', () {
    expect(
      mapSetPasswordError(
        const AuthApiException('A recent sign in is required to update the password'),
      ),
      contains('code e-mail'),
    );
  });

  test('code inconnu : message générique, jamais l\'exception brute', () {
    expect(
      mapSetPasswordError(const AuthApiException('weird', code: 'something_new')),
      contains('définition du mot de passe a échoué'),
    );
  });
}
