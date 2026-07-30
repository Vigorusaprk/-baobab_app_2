import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

/// Image du véhicule. La connexion n'est demandée qu'au moment de réserver,
/// pas à la simple consultation de la fiche.
class CarImageHeader extends StatelessWidget {
  final String imageUrl;

  const CarImageHeader({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      color: AppColors.textSecondary,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.directions_car,
                  size: 100,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : Center(
              child: Icon(
                Icons.directions_car,
                size: 100,
                color: AppColors.textSecondary,
              ),
            ),
    );
  }
}
