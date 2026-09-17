import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_sections.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';

/// Mock des sections **pilotées par les données** de l'accueil, affiché dans
/// un [Skeletonizer] pendant que [BusinessBloc] charge une catégorie.
///
/// Il suit l'ordre réel — un rail large de commerçants, une grille de
/// commerçants, un rail d'offres — et réutilise les squelettes des vrais
/// composants plutôt que de redessiner des formes approchantes : un
/// squelette qui ne ressemble pas à ce qui arrive derrière fait sauter la
/// page au moment du remplacement.
///
/// « À la une » n'y figure pas : la section n'existe que les jours où un
/// commerçant est en campagne, et un squelette qui promet une section
/// absente la moitié du temps ferait sauter la page plus souvent qu'il ne la
/// tiendrait.
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
        BusinessRailSkeleton(width: RailWidth.wide, titleWidth: 160),
        AppDimens.spacerMedium,
        BusinessGridSkeleton(titleWidth: 120),
        AppDimens.spacerMedium,
        OffersCarouselSkeleton(titleWidth: 120),
        SizedBox(height: 100),
      ],
    );
  }
}
