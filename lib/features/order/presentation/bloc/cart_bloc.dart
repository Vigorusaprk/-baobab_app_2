import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/order/domain/entities/cart_item.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';


part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState(items: []));

  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere((i) => i.menuItem == item.menuItem);
    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + item.quantity,
      );
      emit(CartState(items: updatedItems));
    } else {
      emit(CartState(items: [...state.items, item]));
    }
  }

  void removeItem(MenuItem menuItem) {
    final updatedItems = state.items.where((i) => i.menuItem != menuItem).toList();
    emit(CartState(items: updatedItems));
  }

  void updateQuantity(MenuItem menuItem, int quantity) {
    final index = state.items.indexWhere((i) => i.menuItem == menuItem);
    if (index >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      if (quantity <= 0) {
        updatedItems.removeAt(index);
      } else {
        updatedItems[index] = updatedItems[index].copyWith(quantity: quantity);
      }
      emit(CartState(items: updatedItems));
    }
  }

  void clearCart() {
    emit(const CartState(items: []));
  }

  int get totalItems => state.items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => state.items.fold(0.0, (sum, item) => sum + item.totalPrice);
}