import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';

enum OrderStatus { pending, confirmed, preparing, ready, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  /// Le client peut annuler tant que le commerçant n'a pas commencé la
  /// préparation. Au-delà, cela se règle directement avec lui — le serveur
  /// applique la même règle, celle-ci ne fait que masquer un bouton qui
  /// serait de toute façon refusé.
  bool get canBeCancelledByCustomer =>
      this == OrderStatus.pending || this == OrderStatus.confirmed;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  /// La couleur du statut, tirée du système et non d'un arc-en-ciel.
  ///
  /// Elle n'encode pas six catégories mais **qui tient la balle** : ambre
  /// quand on attend une réponse, vert de la marque quand ça avance,
  /// vert de réussite quand c'est prêt, neutre quand c'est terminé, rouge
  /// quand c'est arrêté. Le libellé, lui, dit toujours l'étape exacte —
  /// la couleur n'est jamais le seul porteur de l'information.
  ///
  /// Une commande livrée redevient neutre volontairement : elles finissent
  /// par former l'essentiel de l'historique, et les laisser en vert
  /// noierait les rares qui demandent encore quelque chose.
  Color color(BuildContext context) {
    switch (this) {
      case OrderStatus.pending:
        return OtherTheme.of(context).onWarningContainer;
      case OrderStatus.confirmed:
        return Theme.of(context).colorScheme.secondary;
      case OrderStatus.preparing:
        return Theme.of(context).colorScheme.primary;
      case OrderStatus.ready:
        return OtherTheme.of(context).onSuccessContainer;
      case OrderStatus.delivered:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case OrderStatus.cancelled:
        return Theme.of(context).colorScheme.error;
    }
  }

  /// Le fond de pastille assorti, explicite plutôt qu'obtenu par opacité.
  Color surface(BuildContext context) {
    switch (this) {
      case OrderStatus.pending:
        return OtherTheme.of(context).warningContainer;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return Theme.of(context).colorScheme.primaryContainer;
      case OrderStatus.ready:
        return OtherTheme.of(context).successContainer;
      case OrderStatus.delivered:
        return Theme.of(context).colorScheme.surface;
      case OrderStatus.cancelled:
        return Theme.of(context).colorScheme.errorContainer;
    }
  }
}
