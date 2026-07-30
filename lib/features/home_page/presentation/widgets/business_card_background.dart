import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';

/// Image de fond (ou remplacement par les initiales/icône) d'une carte
/// business. Extrait de business_card_widget.dart pour garder ce fichier
/// concis ; comportement identique.
class BusinessCardBackground extends StatelessWidget {
  final UIBusiness uiBusiness;

  const BusinessCardBackground({super.key, required this.uiBusiness});

  @override
  Widget build(BuildContext context) {
    final hasImage = uiBusiness.business.bgImg.isNotEmpty;
    final Color color = uiBusiness.categoryColor;

    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: hasImage ? null : color,
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(
                uiBusiness.business.bgImg,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _InitialsContainer(
                    color: color,
                    uiBusiness: uiBusiness,
                  );
                },
              ),
            )
          : _InitialsContainer(color: color, uiBusiness: uiBusiness),
    );
  }
}

class _InitialsContainer extends StatelessWidget {
  final Color color;
  final UIBusiness uiBusiness;

  const _InitialsContainer({required this.color, required this.uiBusiness});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      width: double.infinity,
      height: 100,
      child: Center(
        child: Icon(uiBusiness.categoryIcon, size: 80, color: AppColors.white),
      ),
    );
  }
}
