import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

enum OrderStatus {
  pending,    // En attente
  confirmed,  // Confirmée
  preparing,  // En préparation
  ready,      // Prête
  delivered,  // Livrée
  cancelled,  // Annulée
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

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItemId: map['menuItemId'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  double get total => price * quantity;
}

class Order {
  final String id;
  final String establishmentId;
  final String establishmentName;
  final BusinessType? establishmentType; // Type de l'établissement
  final DateTime orderDate;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double totalAmount;
  final OrderStatus status;
  final String? notes;

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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'establishmentId': establishmentId,
      'establishmentName': establishmentName,
      'establishmentType': establishmentType?.index,
      'orderDate': orderDate.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'totalAmount': totalAmount,
      'status': status.index,
      'notes': notes,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      establishmentId: map['establishmentId'],
      establishmentName: map['establishmentName'],
      establishmentType: map['establishmentType'] != null
          ? BusinessType.values[map['establishmentType']]
          : null,
      orderDate: DateTime.parse(map['orderDate']),
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      subtotal: map['subtotal'],
      tax: map['tax'],
      totalAmount: map['totalAmount'],
      status: OrderStatus.values[map['status']],
      notes: map['notes'],
    );
  }
}
