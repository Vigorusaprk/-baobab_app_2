import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:flutter/material.dart';

class CartFooter extends StatelessWidget {
  final BusinessDetailState state;
  final String? restaurantId;

  const CartFooter({super.key, required this.state, this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final totalItems = state.cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
    final totalPrice = state.cartItems.fold(
      0.0,
      (sum, item) => sum + item.total,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total articles : $totalItems',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total: ${totalPrice.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _validateOrder(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text(
                'Valider la commande',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateOrder(
    BuildContext context,
    BusinessDetailState state,
  ) async {
    final sessionUser = SessionService.instance.currentUser;
    if (sessionUser == null) {
      showAuthRequiredCard(
        context,
        message: 'Connectez-vous pour valider votre commande.',
      );
      return;
    }

    final apiService = OrderApiService();
    try {
      await apiService.createOrder(
        userId: sessionUser.id,
        businessId: restaurantId ?? 'unknown',
        items: state.cartItems, // Utilise directement la liste du Bloc
      );

      // Note: Ajoutez un événement 'ClearCart' dans votre BusinessDetailBloc pour vider la liste ici
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande validée !'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
