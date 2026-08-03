import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';

/// Carte promo façon "bannière" — reproduit le design fourni :
/// - Bloc coloré en haut avec un badge "Nouveau" et le nom de
///   l'établissement en grand, en filigrane (watermark).
/// - Bandeau blanc en bas avec le nom en clair, un sous-titre
///   (ex: offre du moment), et un bouton pilule "Voir".
///
/// Widget "bête" (StatelessWidget), sans appel réseau ni logique
/// métier : toutes les données viennent de `uiBusiness` + des
/// paramètres optionnels. La navigation est déléguée via `onTap`,
/// à fournir par l'appelant (ex: context.pushNamed('businessDetail', ...)).
class BusinessPromoCard extends StatelessWidget {
  final UIBusiness uiBusiness;

  /// Sous-titre affiché sous le nom (ex: "Menu d'été · Livraison gratuite").
  /// Si non fourni, retombe sur `business.description`.
  final String? subtitle;

  /// Affiche ou non le badge "Nouveau" en haut à gauche.
  final bool isNew;

  /// Texte du badge (par défaut "Nouveau").
  final String badgeLabel;

  /// Texte du bouton d'action (par défaut "Voir").
  final String actionLabel;

  final VoidCallback? onTap;

  const BusinessPromoCard({
    super.key,
    required this.uiBusiness,
    this.subtitle,
    this.isNew = true,
    this.badgeLabel = 'Nouveau',
    this.actionLabel = 'Voir',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final business = uiBusiness.business;
    final bannerColor = uiBusiness.categoryColor;
    final effectiveSubtitle = subtitle ?? business.description;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Bloc coloré : badge + nom en filigrane ---
            Container(
              width: double.infinity,
              height: 125,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              color: bannerColor,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Nom en grand, en filigrane, centré
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          business.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.28),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: "Poppins",
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Badge "Nouveau"
                  if (isNew)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeLabel,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- Bandeau blanc : nom clair + sous-titre + bouton ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          business.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.titleMedium
                        ),
                        if (effectiveSubtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            effectiveSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Bouton "Voir"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
