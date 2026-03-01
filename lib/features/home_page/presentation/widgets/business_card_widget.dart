import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui';


class BusinessCardWidget extends StatelessWidget {
  final UIBusiness uiBusiness;

  const BusinessCardWidget({super.key, required this.uiBusiness});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Image de fond
            Positioned.fill(
              child: _buildBackGroudImage(),
            ),

            // Gradient protecteur
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Badge de catégorie
            Positioned(
              top: 16,
              right: 16,
              child: _buildCategoryBadge(),
            ),

            // Overlay d'information
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildInfoOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour l'image de profil (grande zone)
  Widget _buildBackGroudImage(){
    final hasImage = uiBusiness.business.bgImg != null && uiBusiness.business.bgImg!.isNotEmpty;
    final Color = uiBusiness.categoryColor;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: hasImage ? null : uiBusiness.categoryColor, // Fond coloré si pas d'image
      ),
      child: hasImage ?
      ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
            uiBusiness.business.bgImg!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Si l'image ne se charge pas, afficher les initiales
            return _buildInitialsContainer(Color);
          },
        ),
      ) : _buildInitialsContainer(Color)
    );
  }

  Widget _buildInitialsContainer(Color color) {
    return Container(
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28)
      ),
      width: double.infinity,
      height: 200,
      child: Center(
        child: Icon(
          uiBusiness.categoryIcon,
          size: 80,
          color: Colors.white,
        )
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: uiBusiness.categoryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 5),
          ),
          child: Icon(uiBusiness.categoryIcon, size: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoOverlay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      uiBusiness.business.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  _buildRatingBadge(),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/location-svgrepo-com (1).svg",
                    height: 14,
                    colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      uiBusiness.business.address,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            uiBusiness.business.rating.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}