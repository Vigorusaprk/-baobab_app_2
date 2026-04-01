import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
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
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

class OrderItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'menu_item_id': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'special_instructions': specialInstructions,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItemId: map['menu_item_id']?.toString() ?? '',
      name: map['name']?.toString() ?? map['item_name']?.toString() ?? '',
      price: _toDouble(map['unit_price']) ?? 0.0,
      quantity: _toInt(map['quantity']) ?? 0,
      specialInstructions: map['special_instructions']?.toString(),
    );
  }

  double get total => price * quantity;
}

class Order {
  final String id;
  final String establishmentId;
  final String establishmentName;
  final BusinessType? establishmentType;
  final DateTime orderDate;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double totalAmount;
  final OrderStatus status;
  final String? notes;
  final String? deliveryAddress;
  final double? deliveryFee;
  final String? paymentMethod;

  Order({
    required this.id,
    required this.establishmentId,
    required this.establishmentName,
    this.establishmentType,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.deliveryAddress,
    this.deliveryFee,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': establishmentId,
      'establishment_name': establishmentName,
      'establishment_type': establishmentType?.index,
      'order_date': orderDate.toIso8601String(),
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total_amount': totalAmount,
      'status': status.index,
      'notes': notes,
      'delivery_address': deliveryAddress,
      'delivery_fee': deliveryFee,
      'payment_method': paymentMethod,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    try {
      // Items
      List<OrderItem> itemsList = [];
      if (map['items'] is List) {
        itemsList = (map['items'] as List)
            .where((item) => item != null)
            .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
            .toList();
      } else if (map['items'] != null) {
        print('items n\'est pas une liste: ${map['items']}');
      }

      // Calcul du sous‑total si non fourni
      double computedSubtotal = 0;
      for (final item in itemsList) {
        computedSubtotal += item.total;
      }

      return Order(
        id: map['id']?.toString() ?? '',
        establishmentId: map['business_id']?.toString() ?? '',
        establishmentName: map['establishment_name']?.toString() ?? '',
        establishmentType: map['establishment_type'] != null
            ? BusinessType.values[map['establishment_type'] as int]
            : null,
        orderDate: DateTime.tryParse(map['order_date']?.toString() ?? '') ?? DateTime.now(),
        items: itemsList,
        subtotal: _toDouble(map['subtotal']) ?? computedSubtotal,
        tax: _toDouble(map['tax']) ?? 0.0,
        totalAmount: _toDouble(map['total_amount']) ?? 0.0,
        status: OrderStatus.values[_toInt(map['status']) ?? 0],
        notes: map['notes']?.toString(),
        deliveryAddress: map['delivery_address']?.toString(),
        deliveryFee: _toDouble(map['delivery_fee']),
        paymentMethod: map['payment_method']?.toString(),
      );
    } catch (e, stack) {
      print('Erreur lors du parsing de la commande: $e');
      print('Données reçues: $map');
      print(stack);
      rethrow;
    }
  }
}

// Fonctions utilitaires
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}