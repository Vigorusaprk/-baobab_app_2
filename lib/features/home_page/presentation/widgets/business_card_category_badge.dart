import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';

/// Badge circulaire (photo de profil ou icône de catégorie) affiché en haut
/// à droite d'une carte business. Extrait de business_card_widget.dart pour
/// garder ce fichier concis ; comportement identique.
class BusinessCardCategoryBadge extends StatelessWidget {
  final UIBusiness uiBusiness;

  const BusinessCardCategoryBadge({super.key, required this.uiBusiness});

  @override
  Widget build(BuildContext context) {
    final businessData = uiBusiness.business;

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(color: uiBusiness.categoryColor.withOpacity(0.7), width: 5.5),
          ),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: businessData.profilImg != null && businessData.profilImg!.isNotEmpty
                ? Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(businessData.profilImg!),
                    fit: BoxFit.cover,
                  )
              ),
            )
                : Icon(uiBusiness.categoryIcon, size: 45, color: uiBusiness.categoryColor),
          ),
        ),
      ),
    );
  }
}
