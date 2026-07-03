import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // Utilisation du BusinessDetailBloc
    final bloc = context.read<BusinessDetailBloc>();
    final state = bloc.state;

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: state.cartItems.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 26),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        height: 150,
                        width: double.infinity,
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E2A3E), Color(0xFF0F172A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              height: 150,
                              width: 130,
                              child: Center(
                                child: Icon(Icons.fastfood, color: Colors.white, size:50),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${item.price} €',
                                            style: const TextStyle(
                                              color: AppColors.black,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/dollar-square(1).svg",
                                              width: 23,
                                              height: 23,
                                              colorFilter: const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn),
                                            ),
                                            SizedBox(width: 5,),
                                            Text(
                                              '${item.total.toStringAsFixed(2)} €',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: AppColors.secondary
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/shopping-cart.svg",
                                              width: 20,
                                              height: 20,
                                              colorFilter: const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn),
                                            ),
                                            SizedBox(width: 5,),
                                            Text(
                                              item.quantity.toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                  color: AppColors.secondary
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildFooter(context, state),
              ],
            ),
    );
  }

  // --- WIDGETS AUXILIAIRES ---

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 16),
                const Text('Votre panier est vide'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 45, right: 10, left: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 3, color: AppColors.secondary),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.secondary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Liste de Commande',
            style: TextStyle(
              fontFamily: AppFonts.primaryFontFamily,
              fontSize: 24,
              fontWeight: AppFonts.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, BusinessDetailState state) {
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
            color: Colors.black.withOpacity(0.2),
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
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) {
      context.go('/login');
      return;
    }

    final apiService = OrderApiService();
    try {
      await apiService.createOrder(
        userId: authState.user.id,
        businessId: restaurantId ?? 'unknown',
        items: state.cartItems, // Utilise directement la liste du Bloc
      );

      // Note: Ajoutez un événement 'ClearCart' dans votre BusinessDetailBloc pour vider la liste ici
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande validée !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildBackgroundOrbes(dynamic item) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: item.imageUrl.startsWith('http')
              ? Image.network(
            item.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          )
              : Image.asset(
            item.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() => Container(
    decoration: BoxDecoration(
      // 1. NOUVEAU STYLE : Dégradé sombre élégant (comme la carte earnings)
      gradient: const LinearGradient(
        colors: [Color(0xFF1E2A3E), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    height: 180,
    width: double.infinity,
    child: Stack(
      children: [
        Positioned(
            right: 10,
            bottom: 5,
            child: const Icon(Icons.fastfood, color: Colors.white, size:150)
        ),
      ],
    ),
  );
}
