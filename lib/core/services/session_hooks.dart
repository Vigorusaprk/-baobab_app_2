import 'dart:async';

/// Ce qu'il faut faire **juste avant** de fermer la session.
///
/// Existe pour une raison de dépendances : le détachement du jeton de
/// notification appartient à la fonctionnalité « notification », mais le
/// moment où il doit avoir lieu appartient à « auth ». Faire importer l'une
/// par l'autre nouerait deux fonctionnalités qui n'ont rien à se dire ; ce
/// point de rendez-vous, lui, ne connaît ni l'une ni l'autre.
///
/// Le branchement se fait au démarrage, dans `main`.
class SessionHooks {
  const SessionHooks._();

  /// Posé par `main`. `null` tant que rien n'est branché — sous test, par
  /// exemple, où il n'y a ni Firebase ni jeton d'appareil.
  static Future<void> Function()? beforeSignOut;

  /// Exécute le crochet sans jamais faire échouer la déconnexion.
  ///
  /// Se déconnecter doit aboutir même si le serveur est injoignable. Un
  /// jeton resté en base est un désagrément ; une déconnexion qui échoue est
  /// un compte qu'on ne peut plus quitter sur un téléphone partagé.
  static Future<void> runBeforeSignOut() async {
    try {
      await beforeSignOut?.call();
    } catch (_) {
      // Voir ci-dessus.
    }
  }
}
