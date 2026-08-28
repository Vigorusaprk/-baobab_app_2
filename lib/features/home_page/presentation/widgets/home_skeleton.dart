import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_list_row.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Mock des sections **pilotées par les données** de l'accueil, affiché dans
/// un [Skeletonizer] pendant que [BusinessBloc] charge une catégorie.
///
/// Il suit le triptyque réel — Nouveautés (rail d'offres), Populaires
/// (commerçants en lignes), Découvrir (rail d'offres) — et réutilise les
/// squelettes des vrais composants plutôt que de redessiner des formes
/// approchantes : un squelette qui ne ressemble pas à ce qui arrive derrière
/// fait sauter la page au moment du remplacement.
///
/// La barre de recherche et la liste des catégories n'en font volontairement
/// pas partie : leur contenu ne dépend d'aucune requête, elles restent
/// affichées telles quelles pendant le chargement — sinon la catégorie que
/// l'utilisateur vient de taper disparaîtrait sous ses doigts.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffersCarouselSkeleton(titleWidth: 100),
        AppDimens.spacerMedium,
        _PopularSectionSkeleton(),
        AppDimens.spacerMedium,
        OffersCarouselSkeleton(titleWidth: 90),
        SizedBox(height: 100),
      ],
    );
  }
}

/// Mirrors [PopularBusinessListView] : titre + « Voir tout », puis trois
/// lignes de commerçant — le serveur en renvoie toujours au plus trois.
class _PopularSectionSkeleton extends StatelessWidget {
  const _PopularSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.appPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bone.text(width: 110, style: AppFonts.titleMedium),
              Bone.text(width: 50, style: AppFonts.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < 3; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: BusinessListRowSkeleton(),
            ),
        ],
      ),
    );
  }
}
