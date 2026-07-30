import 'dart:ui';

import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/plat_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RestaurantInfoBigCard extends StatelessWidget {
  final MenuItem item;
  final String? restaurantId;
  final String? restaurantName;
  final bool isFreeDelivery;

  const RestaurantInfoBigCard({
    super.key,
    this.restaurantId,
    this.restaurantName,
    this.isFreeDelivery = true,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlatDetail(
            menuItem: item,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            isOrderMode: false,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        // Dimensions de la carte
        width: 380,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // 2. Ombre plus prononcée
              color: AppColors.textPrimary.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          child: Stack(
            children: [
              _buildBackgroundOrbes(item),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondaryLight.withOpacity(0.7),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            height: 1.2,
                          ),
                        ),

                        Text(
                          '${item.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/cooking-pot-duotone.svg",
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "20-30 min",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontSize: 12, color: AppColors.white),
                        ),
                        const SizedBox(width: 12),
                        SvgPicture.asset(
                          "assets/icons/delivery-svgrepo-com.svg",
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFreeDelivery
                              ? "Livraison gratuite"
                              : "Frais de livraison",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontSize: 12, color: AppColors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          child: const Icon(Icons.fastfood, color: AppColors.white, size: 150),
        ),
      ],
    ),
  );
}
