import 'package:flutter/material.dart';

/// L'action qui vient d'aboutir, et **ce qu'elle donne le droit de demander**.
///
/// La permission ne se demande pas au moment de la connexion : à cet instant
/// elle n'a aucune justification, et une demande sans raison se refuse. Elle
/// se demande après un acte qui, lui, en appelle une suite — une commande
/// dont on veut suivre l'avancement, une réservation dont on attend la
/// réponse du commerçant.
///
/// Chaque action porte donc **sa** raison principale. Les raisons secondaires
/// sont communes : elles disent ce qu'on gagne d'autre, sans prétendre être
/// le motif du moment.
enum NotificationReason {
  orderPlaced(
    key: 'order',
    title: 'Suivez votre commande',
    main:
        'Nous vous préviendrons dès que le commerçant accepte votre '
        'commande, puis quand elle est prête et quand elle part.',
    icon: Icons.local_shipping_outlined,
  ),

  reservationPlaced(
    key: 'reservation',
    title: 'Sachez si c\'est confirmé',
    main:
        'Votre réservation attend la réponse du commerçant. Nous vous '
        'préviendrons dès qu\'il l\'a confirmée.',
    icon: Icons.event_available_outlined,
  ),

  merchantJoined(
    key: 'merchant',
    title: 'Ne manquez aucune commande',
    main:
        'Vos clients commandent à toute heure. Nous vous préviendrons dès '
        'qu\'une commande ou une réservation arrive.',
    icon: Icons.storefront_outlined,
  );

  const NotificationReason({
    required this.key,
    required this.title,
    required this.main,
    required this.icon,
  });

  /// Sert de clé de mémorisation : c'est par nature d'action qu'on retient
  /// un refus.
  final String key;

  final String title;

  /// La raison du moment, celle qui découle de l'action accomplie.
  final String main;

  final IconData icon;

  /// Ce qu'on gagne d'autre. Volontairement court et au second plan : trois
  /// arguments de même poids n'en font aucun.
  static const List<({IconData icon, String label})> secondary = [
    (
      icon: Icons.local_offer_outlined,
      label: 'Les offres des commerces que vous suivez',
    ),
    (
      icon: Icons.chat_bubble_outline_rounded,
      label: 'Les réponses à vos avis et à vos demandes',
    ),
    (
      icon: Icons.notifications_off_outlined,
      label: 'Rien d\'autre : pas de publicité, et vous pouvez tout couper',
    ),
  ];
}
