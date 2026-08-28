import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

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

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}
