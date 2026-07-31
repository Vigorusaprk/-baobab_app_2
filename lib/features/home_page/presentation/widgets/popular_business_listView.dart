import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:go_router/go_router.dart';

/// Partie "vue" pure de la section Populaires : reçoit une liste déjà
/// prête de [UIBusiness] et affiche l'en-tête + les lignes.
///
/// Ne dépend d'aucun Bloc — réutilisable ailleurs (ex: écran de
/// recherche par catégorie) si besoin d'afficher ce même style de
/// liste sans passer par BusinessBloc.
///
/// ⚠️ Pas de distance affichée : la table `business` n'a pas encore de
/// colonnes `latitude`/`longitude` côté Supabase. Dès qu'elles
/// existeront, on pourra ajouter un `distanceBuilder` sur ce widget.
class PopularBusinessListView extends StatelessWidget {
  final List<UIBusiness> uiBusinesses;
  final String title;
  final VoidCallback? onSeeAllTap;
  final void Function(UIBusiness uiBusiness)? onItemTap;

  const PopularBusinessListView({
    super.key,
    required this.uiBusinesses,
    this.title = 'Populaires',
    this.onSeeAllTap,
    this.onItemTap,
  });

  void _handleTap(BuildContext context, UIBusiness uiBusiness) {
    if (onItemTap != null) {
      onItemTap!(uiBusiness);
      return;
    }
    context.pushNamed(
      'businessDetail',
      pathParameters: {'id': uiBusiness.business.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uiBusinesses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:AppFonts.titleMedium,
              ),
              GestureDetector(
                onTap: onSeeAllTap,
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...uiBusinesses.map(
          (uiBusiness) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PopularBusinessRow(
              uiBusiness: uiBusiness,
              onTap: () => _handleTap(context, uiBusiness),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopularBusinessRow extends StatelessWidget {
  final UIBusiness uiBusiness;
  final VoidCallback onTap;

  const _PopularBusinessRow({required this.uiBusiness, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final business = uiBusiness.business;
    final initial = business.name.isNotEmpty
        ? business.name[0].toUpperCase()
        : '?';

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar rond avec l'initiale du nom
              Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: uiBusiness.categoryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      business.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                        Text(
                          business.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppDimens.spacerSmallWidth,
                        Text(
                            business.type.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "Poppins",
                            color: AppColors.textSecondary,
                          ),
                        ),
                        // Distance volontairement omise : la table `business`
                        // n'a pas encore de latitude/longitude côté Supabase.
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
}
