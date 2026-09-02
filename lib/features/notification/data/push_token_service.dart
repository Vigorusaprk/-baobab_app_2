import 'dart:async';
import 'dart:io' show Platform;

import 'package:baobabe_0_2/core/constants/supabase_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Le cycle de vie du jeton d'appareil, de bout en bout.
///
/// Un jeton ne se pose pas une fois pour toutes. Il change de trois façons,
/// et les trois doivent être couvertes sous peine de notifications qui
/// s'arrêtent sans prévenir — ou, pire, qui partent au mauvais compte :
///
/// 1. **on l'obtient** quand la permission est accordée ;
/// 2. **Firebase le remplace** de lui-même, sans rien demander, et le nouveau
///    doit remonter au serveur ;
/// 3. **le compte change** — nouveau téléphone, téléphone prêté, déconnexion.
///    Le rattachement suit le compte connecté, et la déconnexion détache.
///
/// Le serveur tient l'unicité du jeton : c'est lui qui garantit qu'un
/// appareil ne sert qu'un compte à la fois.
class PushTokenService {
  PushTokenService._();

  static final PushTokenService instance = PushTokenService._();

  StreamSubscription<String>? _refreshes;

  /// Le web a besoin d'une clé VAPID que le projet n'a pas configurée, et la
  /// notification y a de toute façon un tout autre sens. On s'abstient.
  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  /// La permission déjà accordée ? Sans jamais rien demander.
  ///
  /// Sert à savoir si l'on doit ouvrir la feuille d'explication : quelqu'un
  /// qui a déjà dit oui n'a pas à ce qu'on le lui redemande.
  Future<bool> isGranted() async {
    if (!isSupported) return false;
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  /// Ouvre **la boîte de dialogue du système**.
  ///
  /// C'est le seul endroit qui accorde quoi que ce soit : notre feuille
  /// explique, celle-ci autorise. Sur Android, un système qui a déjà été
  /// refusé deux fois ne l'affiche plus et répond `denied` sans rien montrer
  /// — d'où le renvoi vers les réglages, côté appelant.
  Future<bool> requestFromSystem() async {
    if (!isSupported) return false;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (granted) await registerCurrentDevice();
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Envoie le jeton de cet appareil au serveur, pour le compte connecté.
  ///
  /// Idempotent : le serveur fait un `upsert` sur le jeton. On peut donc
  /// l'appeler au démarrage, à chaque connexion et à chaque rafraîchissement
  /// sans se demander si c'est la première fois.
  Future<void> registerCurrentDevice() async {
    if (!isSupported) return;
    try {
      final client = SupabaseClientWrapper.clientOrNull;
      if (client?.auth.currentUser == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      await client!.functions.invoke(
        'register-push-token',
        body: {'token': token, 'platform': _platform},
      );
    } catch (_) {
      // Un enregistrement manqué se rattrape au démarrage suivant. Il ne
      // doit pas remonter jusqu'à l'écran qui l'a déclenché.
    }
  }

  /// Détache cet appareil du compte, **avant** de fermer la session.
  ///
  /// L'ordre compte : après `signOut()` il n'y a plus de jeton de session à
  /// présenter, la ligne resterait en base, et la personne suivante à se
  /// connecter sur ce téléphone recevrait les notifications de la
  /// précédente.
  Future<void> detachCurrentDevice() async {
    if (!isSupported) return;
    try {
      final client = SupabaseClientWrapper.clientOrNull;
      if (client?.auth.currentUser == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      await client!.functions.invoke(
        'unregister-push-token',
        body: {'token': token},
      );
    } catch (_) {
      // Même raison : une déconnexion ne doit pas échouer parce qu'un
      // détachement a échoué.
    }
  }

  /// À appeler une fois au démarrage.
  ///
  /// Écoute le remplacement du jeton par Firebase — qui arrive sans qu'on ait
  /// rien demandé — et renvoie le nouveau. Sans cela, les notifications
  /// s'arrêtent un jour, en silence, et rien dans l'application ne le montre.
  Future<void> start() async {
    if (!isSupported) return;
    _refreshes?.cancel();
    try {
      _refreshes = FirebaseMessaging.instance.onTokenRefresh.listen((_) {
        registerCurrentDevice();
      });
      // Au cas où la permission a été accordée lors d'une session précédente,
      // ou changée dans les réglages du téléphone entre deux lancements.
      if (await isGranted()) await registerCurrentDevice();
    } catch (_) {
      // L'absence de Firebase ne doit pas empêcher l'application de démarrer.
    }
  }

  @visibleForTesting
  Future<void> stop() async {
    await _refreshes?.cancel();
    _refreshes = null;
  }
}
