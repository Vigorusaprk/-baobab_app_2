import 'package:app_settings/app_settings.dart';
import 'package:baobabe_0_2/features/notification/data/notification_preferences.dart';
import 'package:baobabe_0_2/features/notification/data/push_token_service.dart';
import 'package:baobabe_0_2/features/notification/domain/notification_reason.dart';
import 'package:baobabe_0_2/features/notification/presentation/widgets/notification_permission_sheet.dart';
import 'package:flutter/material.dart';

/// Le point d'entrée unique : « une action vient d'aboutir, faut-il demander
/// les notifications, et si oui comment ? ».
///
/// Appelé après l'acte, jamais après la connexion. Une seule ligne à écrire
/// dans l'écran appelant :
///
/// ```dart
/// await NotificationPrompt.maybeAsk(context, NotificationReason.orderPlaced);
/// ```
///
/// Tout le reste — se souvenir, décider, expliquer, passer le relais au
/// système — est ici ou dans les deux pièces qu'il assemble.
class NotificationPrompt {
  const NotificationPrompt._();

  /// Demande, si et seulement si c'est légitime.
  ///
  /// Ne lève jamais et ne bloque rien : l'action qui l'a déclenchée a déjà
  /// abouti, et une demande de permission ne doit pas pouvoir la ternir.
  static Future<void> maybeAsk(
    BuildContext context,
    NotificationReason reason,
  ) async {
    try {
      final service = PushTokenService.instance;
      if (!service.isSupported) return;

      var preferences = await NotificationPreferences.load();
      if (!preferences.shouldAsk(reason)) return;

      // Déjà accordée dans les réglages du téléphone, sans passer par nous ?
      // Alors il n'y a rien à demander : on note et on enregistre l'appareil.
      if (await service.isGranted()) {
        await preferences.markGranted();
        await service.registerCurrentDevice();
        return;
      }

      if (!context.mounted) return;
      final answer = await showNotificationPermissionSheet(
        context,
        reason: reason,
      );

      if (answer == PermissionAnswer.decline) {
        await preferences.markRefused(reason);
        return;
      }

      // Le relais au système. C'est lui, et lui seul, qui autorise.
      final granted = await service.requestFromSystem();
      if (granted) {
        await preferences.markGranted();
        return;
      }

      // Refusé par le système. Sur Android, après deux refus, la boîte ne
      // réapparaît plus jamais : dire « réessayez » serait mentir. On oriente
      // vers le seul endroit qui peut encore l'accorder.
      preferences = await preferences.markRefused(reason);
      if (!context.mounted) return;
      _offerSettings(context);
    } catch (_) {
      // Voir la remarque en tête : jamais au détriment de l'action réussie.
    }
  }

  /// Ouvre les réglages de notification du téléphone.
  ///
  /// Public parce que le réglage « Notifications » des paramètres de
  /// l'application s'en sert aussi : c'est la porte de sortie de quelqu'un
  /// qui a refusé et change d'avis.
  static Future<void> openSystemSettings() =>
      AppSettings.openAppSettings(type: AppSettingsType.notification);

  static void _offerSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Les notifications sont bloquées par votre téléphone.',
        ),
        action: SnackBarAction(
          label: 'Réglages',
          onPressed: openSystemSettings,
        ),
      ),
    );
  }
}
