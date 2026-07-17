import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/cart_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class MenuTopBar extends StatelessWidget {
  final String? restaurantId;
  final String? restaurantName;
  final BusinessType? restaurantType;

  const MenuTopBar({
    super.key,
    this.restaurantId,
    this.restaurantName,
    this.restaurantType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 45, right: 10, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/delivery-svgrepo-com.svg',
                height: 35,
                colorFilter: const ColorFilter.mode(
                  AppColors.secondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Commander',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          BlocBuilder<BusinessDetailBloc, BusinessDetailState>(
            builder: (context, state) {
              // Calcul du total des articles via la liste du bloc
              final totalItems = state.cartItems.fold(0, (sum, item) => sum + item.quantity);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 3, color: AppColors.secondary)
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/shopping-cart.svg",
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn),
                      ),
                      onPressed: () {
                        // On récupère le bloc existant
                        final bloc = context.read<BusinessDetailBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: bloc, // On passe l'instance existante à la nouvelle route
                              child: CartPage(
                                restaurantId: restaurantId,
                                restaurantName: restaurantName,
                                restaurantType: restaurantType,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (totalItems > 0)
                    Positioned(
                      right: 0.50,
                      top: 0.50,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$totalItems',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
