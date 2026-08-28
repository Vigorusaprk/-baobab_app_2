import 'package:baobabe_0_2/features/order/domain/entities/order_parsing_utils.dart';

class OrderItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;

  /// L'offre commandée, quand la commande est passée par le moule `offers`.
  /// C'est elle que le client note ensuite — la note du commerce découle
  /// de celles de ses offres.
  final String? offerId;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
    this.offerId,
  });

  // --- Partie modifiée : Ajout de la méthode copyWith ---
  OrderItem copyWith({
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
    String? specialInstructions,
    String? offerId,
  }) {
    return OrderItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      offerId: offerId ?? this.offerId,
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
      'offer_id': offerId,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    final menuItem = map['menu_items'] is Map
        ? map['menu_items'] as Map<String, dynamic>
        : null;
    return OrderItem(
      menuItemId:
          map['menu_item_id']?.toString() ?? menuItem?['id']?.toString() ?? '',
      name:
          map['name']?.toString() ??
          map['item_name']?.toString() ??
          menuItem?['item_name']?.toString() ??
          menuItem?['name']?.toString() ??
          '',
      price:
          toDoubleOrNull(
            map['unit_price'] ?? map['price'] ?? menuItem?['price'],
          ) ??
          0.0,
      quantity: toIntOrNull(map['quantity']) ?? 0,
      specialInstructions: map['special_instructions']?.toString(),
      offerId: map['offer_id']?.toString(),
    );
  }

  double get total => price * quantity;
}
