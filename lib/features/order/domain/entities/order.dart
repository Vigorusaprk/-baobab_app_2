import 'package:baobabe_0_2/core/themes/app_colors.dart';
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

  // --- Partie modifiée : Ajout de la méthode copyWith ---
  OrderItem copyWith({
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
    String? specialInstructions,
  }) {
    return OrderItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
  // -----------------------------------------------------

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
    final menuItem = map['menu_items'] is Map ? map['menu_items'] as Map<String, dynamic> : null;
    return OrderItem(
      menuItemId: map['menu_item_id']?.toString() ?? menuItem?['id']?.toString() ?? '',
      name: map['name']?.toString() ??
          map['item_name']?.toString() ??
          menuItem?['item_name']?.toString() ??
          menuItem?['name']?.toString() ??
          '',
      price: _toDouble(map['unit_price'] ?? map['price'] ?? menuItem?['price']) ?? 0.0,
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
  final String? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
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
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
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
      final dynamic itemsValue = map['items'] ?? map['order_items'];
      if (itemsValue is List) {
        itemsList = itemsValue
            .where((item) => item != null)
            .map((item) {
              if (item is Map<String, dynamic>) {
                return OrderItem.fromMap(item);
              }
              return OrderItem.fromMap(Map<String, dynamic>.from(item as Map));
            })
            .toList();
      } else if (itemsValue is Map<String, dynamic>) {
        itemsList = [OrderItem.fromMap(itemsValue)];
      } else if (itemsValue != null) {
        final normalized = _normalizeToList(itemsValue);
        if (normalized != null) {
          itemsList = normalized
              .map((item) => OrderItem.fromMap(item))
              .toList();
        } else {
          print('Order.fromMap: items n\'est pas une liste: $itemsValue');
        }
      }

      // Calcul du sous‑total si non fourni
      double computedSubtotal = 0;
      for (final item in itemsList) {
        computedSubtotal += item.total;
      }

      return Order(
        id: map['id']?.toString() ?? '',
        establishmentId: map['business_id']?.toString() ?? '',
        establishmentName: map['establishment_name']?.toString() ?? map['business_name']?.toString() ?? map['name']?.toString() ?? '',
        customerId: map['customer'] is Map ? map['customer']['id']?.toString() : map['user_id']?.toString(),
        customerName: map['customer'] is Map ? map['customer']['name']?.toString() : map['customer_name']?.toString(),
        customerEmail: map['customer'] is Map ? map['customer']['email']?.toString() : null,
        customerPhone: map['customer'] is Map ? map['customer']['phone']?.toString() : null,
        establishmentType: _parseBusinessType(map['establishment_type']),
        orderDate: DateTime.tryParse(map['order_date']?.toString() ?? map['created_at']?.toString() ?? '') ?? DateTime.now(),
        items: itemsList,
        subtotal: _toDouble(map['subtotal']) ?? computedSubtotal,
        tax: _toDouble(map['tax']) ?? 0.0,
        // Support databases that use either `total_amount` or `total_price`
        totalAmount: _toDouble(map['total_amount'] ?? map['total_price']) ?? 0.0,
        status: _parseOrderStatus(map['status']),
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

  String get typeName {
    switch (establishmentType) {
      case BusinessType.hotel:
        return 'Hôtel';
      case BusinessType.carRental:
        return 'Location de véhicule';
      case BusinessType.travelAgency:
        return 'Voyage en bus';
      case BusinessType.spa:
        return 'Spa & Bien-être';
      case BusinessType.cinema:
        return 'Cinéma';
      case BusinessType.tourism:
        return 'Tourisme';
      case BusinessType.restaurant:
        return 'Restaurant';
      case BusinessType.fastFood:
        return 'Fast Food';
      case BusinessType.shopping:
        return 'Shopping';
      case BusinessType.mall:
        return 'Centre Commercial';
      case BusinessType.other:
        return 'Business';
      default:
        return 'Business';
    }
  }

  static List<Map<String, dynamic>>? _normalizeToList(dynamic value) {
    if (value is List) {
      return value
          .where((item) => item is Map)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }
    return null;
  }


  IconData get typeIcon {
    switch (establishmentType) {
      case BusinessType.hotel:
        return Icons.hotel;
      case BusinessType.carRental:
        return Icons.directions_car;
      case BusinessType.travelAgency:
        return Icons.directions_bus;
      case BusinessType.spa:
        return Icons.spa;
      case BusinessType.cinema:
        return Icons.movie;
      case BusinessType.tourism:
        return Icons.tour;
      case BusinessType.restaurant:
        return Icons.restaurant;
      case BusinessType.fastFood:
        return Icons.fastfood;
      case BusinessType.shopping:
        return Icons.store;
      case BusinessType.mall:
        return Icons.apartment;
      case BusinessType.other:
        return Icons.business;
      default:
        return Icons.business;
    }
  }

  Color get typeColor {
    switch (establishmentType) {
      case BusinessType.hotel:
        return AppColors.hotel;
      case BusinessType.carRental:
        return AppColors.carRental;
      case BusinessType.travelAgency:
        return AppColors.travelAgency;
      case BusinessType.spa:
        return AppColors.spa;
      case BusinessType.cinema:
        return AppColors.cinema;
      case BusinessType.tourism:
        return AppColors.tourism;
      case BusinessType.restaurant:
        return AppColors.restaurant;
      case BusinessType.fastFood:
        return AppColors.fastFood;
      case BusinessType.shopping:
        return AppColors.shopping;
      case BusinessType.mall:
        return AppColors.mall;
      case BusinessType.other:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

BusinessType? _parseBusinessType(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    if (value >= 0 && value < BusinessType.values.length) {
      return BusinessType.values[value];
    }
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    for (final type in BusinessType.values) {
      if (type.name.toLowerCase() == normalized) {
        return type;
      }
    }

    switch (normalized) {
      case 'car_rental':
      case 'car rental':
        return BusinessType.carRental;
      case 'travel_agency':
      case 'travel agency':
      case 'travel':
        return BusinessType.travelAgency;
      case 'fast_food':
      case 'fast food':
        return BusinessType.fastFood;
      case 'shopping':
        return BusinessType.shopping;
      case 'mall':
        return BusinessType.mall;
      case 'hotel':
        return BusinessType.hotel;
      case 'cinema':
        return BusinessType.cinema;
      case 'spa':
        return BusinessType.spa;
      case 'tourism':
      case 'toursime':
        return BusinessType.tourism;
      case 'restaurant':
        return BusinessType.restaurant;
      default:
        return BusinessType.other;
    }
  }

  return null;
}



OrderStatus _parseOrderStatus(dynamic value) {
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    for (final status in OrderStatus.values) {
      if (status.name == normalized) {
        return status;
      }
    }
  }

  final index = _toInt(value);
  if (index != null && index >= 0 && index < OrderStatus.values.length) {
    return OrderStatus.values[index];
  }

  return OrderStatus.pending;
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
