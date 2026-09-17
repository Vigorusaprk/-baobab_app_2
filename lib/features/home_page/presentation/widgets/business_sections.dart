import 'package:baobabe_0_2/core/services/metrics_service.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/business_card.dart';
import 'package:baobabe_0_2/core/widgets/section_header.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'business_sections_skeletons.dart';

/// Les trois sections de commerçants de l'accueil.
///
/// L'accueil met en avant des **commerçants**. Chaque section est un rail ou
/// une grille de [BusinessCard.tile] ; la forme de la carte ne change pas,
/// seule sa largeur change avec l'importance de la section.

/// La largeur d'une tuile dans un rail, en part de l'écran. Plus la section
/// pèse, plus la tuile est large — et moins on en voit d'un coup.
enum RailWidth {
  /// « À la une » : presque toute la largeur, la suivante dépasse juste
  /// assez pour dire qu'il y en a d'autres.
  hero(0.84),

  /// « Nouveaux » : deux visibles, la troisième entamée.
  wide(0.62);

  const RailWidth(this.fraction);

  final double fraction;
}

/// Un rail horizontal de commerçants.
class BusinessRail extends StatelessWidget {
  const BusinessRail({
    super.key,
    required this.title,
    required this.businesses,
    required this.width,
    this.subtitle,
    this.onSeeAll,
    this.featuredOfferOf,
    this.onTapOverride,
  });

  final String title;
  final String? subtitle;
  final List<Business> businesses;
  final RailWidth width;
  final VoidCallback? onSeeAll;

  /// Pour « À la une » : l'offre qu'une campagne pousse, par commerce.
  final String? Function(Business)? featuredOfferOf;

  /// Pour « À la une » : ce que le toucher ouvre, quand ce n'est pas la
  /// fiche du commerce. Sans lui, la fiche.
  final void Function(BuildContext, Business)? onTapOverride;

  @override
  Widget build(BuildContext context) {
    // Une section sans contenu disparaît entièrement : mieux vaut aucune
    // section qu'un titre suivi du vide.
    if (businesses.isEmpty) return const SizedBox.shrink();

    final tileWidth =
        (MediaQuery.sizeOf(context).width - AppDimens.appPaddingValue * 2) *
        width.fraction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, subtitle: subtitle, onSeeAll: onSeeAll),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: AppDimens.appPadding,
          // Une ligne dont la hauteur est celle de la plus haute tuile : la
          // carte décide de sa hauteur (le texte varie), pas le rail.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < businesses.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  SizedBox(
                    width: tileWidth,
                    child: BusinessCard.tile(
                      business: businesses[i],
                      featuredOffer: featuredOfferOf?.call(businesses[i]),
                      onTap: () => onTapOverride != null
                          ? onTapOverride!(context, businesses[i])
                          : openBusiness(context, businesses[i]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Une grille de commerçants, deux par ligne.
class BusinessGrid extends StatelessWidget {
  const BusinessGrid({
    super.key,
    required this.title,
    required this.businesses,
    this.subtitle,
    this.onSeeAll,
  });

  final String title;
  final String? subtitle;
  final List<Business> businesses;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (businesses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, subtitle: subtitle, onSeeAll: onSeeAll),
        const SizedBox(height: 4),
        Padding(
          padding: AppDimens.appPadding,
          // Deux colonnes par paires de lignes plutôt qu'un `GridView` à
          // ratio fixe : la hauteur d'une tuile dépend de son texte, et un
          // ratio figé finit toujours par tronquer une pastille.
          child: Column(
            children: [
              for (var i = 0; i < businesses.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: BusinessCard.tile(
                          business: businesses[i],
                          onTap: () => openBusiness(context, businesses[i]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: i + 1 < businesses.length
                            ? BusinessCard.tile(
                                business: businesses[i + 1],
                                onTap: () =>
                                    openBusiness(context, businesses[i + 1]),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// « À la une » : les commerçants en campagne. Section à part, jamais mêlée
/// aux autres ; un même commerce n'y paraît qu'une fois.
///
/// Le toucher est mesuré — c'est ce qui distingue une campagne vue d'une
/// campagne qui a servi — et ouvre l'offre visée quand il y en a une, la
/// fiche sinon.
class FeaturedBusinessesSection extends StatelessWidget {
  const FeaturedBusinessesSection({super.key, required this.featured});

  final List<FeaturedBusiness> featured;

  @override
  Widget build(BuildContext context) {
    final byId = {for (final f in featured) f.business.id: f};

    return BusinessRail(
      title: 'À la une',
      subtitle: 'Les adresses qu\'il faut voir cette semaine.',
      businesses: featured.map((f) => f.business).toList(),
      width: RailWidth.hero,
      featuredOfferOf: (business) => byId[business.id]?.offer?.name,
      onTapOverride: (context, business) {
        final entry = byId[business.id];
        MetricsService.instance.click(
          businessId: business.id,
          offerId: entry?.offer?.id,
        );
        final offer = entry?.offer;
        if (offer != null) {
          context.pushNamed('offerDetail', pathParameters: {'id': offer.id});
        } else {
          openBusiness(context, business);
        }
      },
    );
  }
}

void openBusiness(BuildContext context, Business business) {
  context.pushNamed('businessDetail', pathParameters: {'id': business.id});
}
