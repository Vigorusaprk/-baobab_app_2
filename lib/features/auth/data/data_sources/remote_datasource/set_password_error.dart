import 'package:supabase_flutter/supabase_flutter.dart';

/// Traduit une erreur de mise à jour du mot de passe Supabase en message
/// lisible en français.
///
/// Séparé du datasource pour être testable sans monter un client : la
/// frontière qui nous intéresse est la traduction, qui est pure.
String mapSetPasswordError(AuthException e) {
  final code = (e.code ?? '').toLowerCase();
  final message = e.message.toLowerCase();

  if (code == 'same_password') {
    return 'Le nouveau mot de passe doit être différent de l\'ancien.';
  }
  if (code == 'session_expired') {
    return 'Votre session a expiré. Reconnectez-vous puis réessayez de '
        'définir le mot de passe.';
  }
  // La mise à jour du mot de passe exige une connexion récente : si la
  // session est vieille, le serveur refuse. Le code exact a varié selon les
  // versions de GoTrue, d'où le repli sur le message côté serveur.
  if (code.contains('reauth') ||
      message.contains('reauthenticat') ||
      message.contains('recent')) {
    return 'Pour votre sécurité, reconnectez-vous par code e-mail avant de '
        'définir votre mot de passe.';
  }
  return 'La définition du mot de passe a échoué. Vérifiez votre connexion '
      'puis réessayez.';
}
