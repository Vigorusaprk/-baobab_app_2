import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/order/presentation/bloc/cart_bloc.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/themes/app_diemens.dart';
import '../../../../../../core/themes/app_fonts.dart';

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
    final cubit = context.read<CartCubit>();
    final state = cubit.state;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: state.items.isEmpty
          ? Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:45, right: 10, left: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondaryLight,
                          AppColors.secondaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primaryLight,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Row(
                    children: [
                      const SizedBox(width: AppDimens.PADDING_12),
                      const Text(
                        'Liste de Commande',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFontFamily,
                          fontSize: 24,
                          fontWeight: AppFonts.bold,
                          color: AppColors.secondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Votre panier est vide'),
                ],
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:45, right: 10, left: 10),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondaryLight,
                        AppColors.secondaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryLight,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: 10,),
                Row(
                  children: [
                    const SizedBox(width: AppDimens.PADDING_12),
                    const Text(
                      'Liste de Commande',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFontFamily,
                        fontSize: 24,
                        fontWeight: AppFonts.bold,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  width: 280,
                  height: 80,
                  child: ListTile(
                    leading: const Icon(Icons.fastfood, size: 50, color: AppColors.primary,),
                    title: Text(item.menuItem.itemName, style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w600),),
                    subtitle: Text('${item.menuItem.price} €', style: TextStyle(color: AppColors.primary),),
                    trailing: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Text('${item.quantity}', style: TextStyle(fontSize: 15),),
                        )
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '${cubit.totalPrice.toStringAsFixed(2)} €',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _validateOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Valider la commande', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateOrder(BuildContext context) async {
    final cubit = context.read<CartCubit>();
    final state = cubit.state;
    if (state.items.isEmpty) return;

    // Récupérer l'utilisateur connecté
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) {
      // Rediriger vers la page de connexion
      context.go('/login');
      return;
    }
    final userId = authState.user.id;

    final orderItems = state.items.map((item) => OrderItem(
      menuItemId: item.menuItem.id.toString(),
      name: item.menuItem.itemName,
      price: item.menuItem.price,
      quantity: item.quantity,
    )).toList();

    final apiService = OrderApiService();

    try {
      await apiService.createOrder(
        userId: userId,
        businessId: restaurantId ?? 'unknown',
        items: orderItems,
      );

      cubit.clearCart();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande validée !'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    }
  }
}