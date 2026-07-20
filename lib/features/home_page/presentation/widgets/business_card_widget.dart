import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_card_background.dart';
import 'package:flutter/material.dart';

/// Carte de présentation d'un établissement — style flat/minimaliste
/// (inspiré Uber Eats / Deliveroo) : photo en haut, contenu sur fond
/// blanc en dessous, couleurs plates, ombre légère, typographie forte.
///
/// ⚠️ Séparation des responsabilités conservée : StatelessWidget pur,
/// aucun appel réseau ni calcul métier. `rating` vient directement de
/// `uiBusiness.business.rating`, maintenu à jour côté base de données
/// par le trigger Postgres (migration `auto_update_business_rating`).
class BusinessCardWidget extends StatelessWidget {
  final UIBusiness uiBusiness;

  const BusinessCardWidget({super.key, required this.uiBusiness});

  @override
  Widget build(BuildContext context) {
    final categoryColor = uiBusiness.categoryColor;
    final business = uiBusiness.business;
    final hasDescription = business.description != null && business.description!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Photo (partie haute, coins arrondis en haut uniquement) ---
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BusinessCardBackground(uiBusiness: uiBusiness),

                  // Tag catégorie — pastille pleine couleur, plate
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        business.type.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins",
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),

                  // Pastille de note — fond blanc plat, ombre minimale
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            business.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Contenu (partie basse, fond blanc) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  business.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Poppins",
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasDescription) ...[
                  const SizedBox(height: 6),
                  Text(
                    business.description!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontFamily: "Poppins",
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}