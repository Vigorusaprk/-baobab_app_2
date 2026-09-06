import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Ce qui se passe quand on **touche** une notification.
///
/// Sans ce service, la route transportée dans le message ne servait à rien :
/// toucher une notification ouvrait l'application sur l'accueil, et il
/// fallait retrouver soi-même la commande dont on venait d'être prévenu.
///
/// Trois moments, et les trois comptent :
///
/// 1. l'application était **fermée** — le message qui l'a réveillée est dans
///    `getInitialMessage()`, et il n'arrive jamais dans le flux ;
/// 2. l'application était **en arrière-plan** — `onMessageOpenedApp` ;
/// 3. l'application était **au premier plan** — rien à ouvrir, mais une
///    notification vient de naître : la pastille doit changer.
///
/// La route vient du champ `route` posé par le trigger de la base. Une route
/// vide ne mène nulle part et on ne bouge pas : mieux vaut laisser
/// l'utilisateur où il est que le jeter sur un écran au hasard.
class PushNavigationService {
  PushNavigationService._();

  static final PushNavigationService instance = PushNavigationService._();

  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<RemoteMessage>? _foreground;

  /// À appeler une fois, quand le routeur est posé.
  ///
  /// [onForeground] est appelé pour un message reçu application ouverte :
  /// c'est là que le fil se relit, pour que la pastille dise la vérité sans
  /// attendre que l'on ouvre l'écran.
  Future<void> start({
    required GoRouter router,
    VoidCallback? onForeground,
  }) async {
    if (kIsWeb) return;

    try {
      await _opened?.cancel();
      await _foreground?.cancel();

      _opened = FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _go(router, message);
      });

      _foreground = FirebaseMessaging.onMessage.listen((_) {
        onForeground?.call();
      });

      // Le message qui a réveillé l'application. Il n'apparaît dans aucun
      // flux : ne pas le lire ici, c'est perdre le seul cas où la
      // notification était la raison même de l'ouverture.
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        // Après la première image : le routeur n'a pas encore d'arbre à
        // pousser tant que la première trame n'est pas rendue.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _go(router, initial);
        });
      }
    } catch (_) {
      // Pas de Firebase, pas de navigation par notification — et surtout
      // pas d'application qui refuse de démarrer pour autant.
    }
  }

  void _go(GoRouter router, RemoteMessage message) {
    final route = message.data['route'];
    if (route is! String || route.isEmpty || !route.startsWith('/')) return;
    router.push(route);
  }

  @visibleForTesting
  Future<void> stop() async {
    await _opened?.cancel();
    await _foreground?.cancel();
    _opened = null;
    _foreground = null;
  }
}
