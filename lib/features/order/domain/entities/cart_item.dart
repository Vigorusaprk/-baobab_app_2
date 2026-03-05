import 'package:equatable/equatable.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';

class CartItem extends Equatable {
  final MenuItem menuItem;
  final int quantity;

  const CartItem({required this.menuItem, required this.quantity});

  double get totalPrice => menuItem.price * quantity;

  CartItem copyWith({MenuItem? menuItem, int? quantity}) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object> get props => [menuItem, quantity];
}