import 'package:baobabe_0_2/core/services/metrics_service.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/offer_card.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// « Mise en avant » : les offres que des commerçants ont payé pour montrer.
///
/// Tenue **à part** des trois autres sections, et jamais mêlée à elles.
/// Glisser une offre payée au milieu des mieux notées ferait passer de la
/// publicité pour du mérite : chaque carte porte donc son étiquette
/// « Sponsorisé », et le sous-titre le dit une fois pour toutes.
///
/// Le clic est mesuré : c'est la seule chose qui distingue une campagne vue
/// d'une campagne qui a servi, et le commerçant la lit dans son espace.
class SponsoredSection extends StatelessWidget {
  const SponsoredSection({super.key, required this.offers});

  final List<SponsoredOffer> offers;

  @override
  Widget build(BuildContext context) {
    // Aucune campagne en cours : pas de titre suivi du vide. La section
    // n'existe que les jours où quelqu'un a payé.
    if (offers.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimens.appPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mise en avant', style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                'Des commerces qui paient pour être vus ici.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: OffersCarouselSection.railHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: AppDimens.appPadding,
            itemCount: offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final sponsored = offers[index];
              final offer = sponsored.offer;

              return SizedBox(
                width: OffersCarouselSection.cardWidth,
                child: OfferCard(
                  offer: offer,
                  sponsored: true,
                  onTap: () {
                    final businessId = offer.businessId;
                    if (businessId != null) {
                      MetricsService.instance.click(
                        businessId: businessId,
                        offerId: offer.id,
                      );
                    }
                    context.pushNamed(
                      'offerDetail',
                      pathParameters: {'id': offer.id},
                      extra: offer.fulfilment,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
