import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/cart_empty_state.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/cart_footer.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/cart_header.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/cart_item_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

class CartPage extends StatelessWidget {
  final String? restaurantId;
  final String? restaurantName;
  final BusinessType? restaurantType;

  const CartPage({
    super.key,
    this.restaurantId,
    this.restaurantName,
    this.restaurantType,
  });

  @override
  Widget build(BuildContext context) {
    // Utilisation du BusinessDetailBloc
    final bloc = context.read<BusinessDetailBloc>();
    final state = bloc.state;

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: state.cartItems.isEmpty
          ? const CartEmptyState()
          : Column(
              children: [
                const CartHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return CartItemRow(item: item);
                    },
                  ),
                ),
                CartFooter(state: state, restaurantId: restaurantId),
              ],
            ),
    );
  }
}
