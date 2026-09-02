import 'dart:convert';

import 'package:baobabe_0_2/core/database/local_cache.dart';
import 'package:baobabe_0_2/features/notification/domain/notification_reason.dart';

/// La mémoire de ce qu'on a déjà demandé, et de ce qu'on a obtenu.
///
/// Elle tient à elle seule la règle du produit, et c'est **la seule pièce du
/// dispositif qui décide quoi que ce soit** — d'où le fait qu'elle ne touche
/// ni à Firebase, ni à un widget : elle se teste sans émulateur.
///
/// La règle :
///
/// - **accepté une fois, plus jamais demandé.** La permission est accordée à
///   l'application, pas à une action ; la redemander serait au mieux inutile,
///   au pire agaçant ;
/// - **refusé, on ne redemande pas pour la même nature d'action.** Insister
///   sur le même prétexte, c'est du harcèlement ;
/// - **une action d'une autre nature peut reposer la question, une fois.**
///   Refuser pour une commande ne veut pas dire refuser pour son commerce ;
/// - **au-delà de deux refus, plus jamais.** Il reste les réglages.
class NotificationPreferences {
  const NotificationPreferences._({
    required this.granted,
    required this.refused,
  });

  /// La permission a été accordée au moins une fois.
  final bool granted;

  /// Les natures d'action pour lesquelles on a essuyé un refus.
  final List<String> refused;

  static const String _key = 'notification_permission_state';

  static const NotificationPreferences empty = NotificationPreferences._(
    granted: false,
    refused: [],
  );

  /// Nombre de refus au-delà duquel on ne demande plus rien.
  static const int refusalLimit = 2;

  static Future<NotificationPreferences> load() async {
    final raw = await LocalCache.instance.getCache(_key);
    if (raw == null) return empty;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return NotificationPreferences._(
        granted: json['granted'] as bool? ?? false,
        refused: (json['refused'] as List?)?.cast<String>() ?? const [],
      );
    } catch (_) {
      // Un cache illisible vaut un cache vide : on repart de zéro plutôt que
      // de rester bloqué sur une écriture corrompue.
      return empty;
    }
  }

  Future<void> _save() => LocalCache.instance.saveCache(
    _key,
    jsonEncode({'granted': granted, 'refused': refused}),
  );

  /// Faut-il ouvrir la feuille pour cette action ?
  bool shouldAsk(NotificationReason reason) {
    if (granted) return false;
    if (refused.contains(reason.key)) return false;
    return refused.length < refusalLimit;
  }

  /// Plus rien ne sera demandé : ni maintenant, ni pour une autre action.
  bool get exhausted => granted || refused.length >= refusalLimit;

  Future<NotificationPreferences> markGranted() async {
    final next = NotificationPreferences._(granted: true, refused: refused);
    await next._save();
    return next;
  }

  Future<NotificationPreferences> markRefused(NotificationReason reason) async {
    if (refused.contains(reason.key)) return this;
    final next = NotificationPreferences._(
      granted: granted,
      refused: [...refused, reason.key],
    );
    await next._save();
    return next;
  }

  /// Remet le compteur à zéro.
  ///
  /// Sert au réglage « Notifications » : quelqu'un qui l'active lui-même
  /// revient sur son refus, et il serait absurde de continuer à le lui
  /// opposer.
  static Future<void> reset() => LocalCache.instance.removeCache(_key);
}
