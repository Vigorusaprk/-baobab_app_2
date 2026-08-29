import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_item.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_parsing_utils.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_status.dart';

export 'package:baobabe_0_2/features/order/domain/entities/order_item.dart';
export 'package:baobabe_0_2/features/order/domain/entities/order_status.dart';

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
        itemsList = itemsValue.where((item) => item != null).map((item) {
          if (item is Map<String, dynamic>) {
            return OrderItem.fromMap(item);
          }
          return OrderItem.fromMap(Map<String, dynamic>.from(item as Map));
        }).toList();
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
        establishmentName:
            map['establishment_name']?.toString() ??
            map['business_name']?.toString() ??
            map['name']?.toString() ??
            '',
        customerId: map['customer'] is Map
            ? map['customer']['id']?.toString()
            : map['user_id']?.toString(),
        customerName: map['customer'] is Map
            ? map['customer']['name']?.toString()
            : map['customer_name']?.toString(),
        customerEmail: map['customer'] is Map
            ? map['customer']['email']?.toString()
            : null,
        customerPhone: map['customer'] is Map
            ? map['customer']['phone']?.toString()
            : null,
        establishmentType: parseBusinessType(map['establishment_type']),
        orderDate:
            DateTime.tryParse(
              map['order_date']?.toString() ??
                  map['created_at']?.toString() ??
                  '',
            ) ??
            DateTime.now(),
        items: itemsList,
        subtotal: toDoubleOrNull(map['subtotal']) ?? computedSubtotal,
        tax: toDoubleOrNull(map['tax']) ?? 0.0,
        // Support databases that use either `total_amount` or `total_price`
        totalAmount:
            toDoubleOrNull(map['total_amount'] ?? map['total_price']) ?? 0.0,
        status: parseOrderStatus(map['status']),
        notes: map['notes']?.toString(),
        deliveryAddress: map['delivery_address']?.toString(),
        deliveryFee: toDoubleOrNull(map['delivery_fee']),
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

  /// Voir [UIBusiness.categoryColor] : la palette catégorielle vit dans le
  /// thème, donc la couleur se lit avec un contexte.
  Color typeColor(BuildContext context) {
    final palette = OtherTheme.of(context).categories;
    switch (establishmentType) {
      case BusinessType.hotel:
        return palette.hotel;
      case BusinessType.carRental:
        return palette.carRental;
      case BusinessType.travelAgency:
        return palette.travelAgency;
      case BusinessType.spa:
        return palette.spa;
      case BusinessType.cinema:
        return palette.cinema;
      case BusinessType.tourism:
        return palette.tourism;
      case BusinessType.restaurant:
        return palette.restaurant;
      case BusinessType.fastFood:
        return palette.fastFood;
      case BusinessType.shopping:
        return palette.shopping;
      case BusinessType.mall:
        return palette.mall;
      default:
        return palette.fallback;
    }
  }
}
