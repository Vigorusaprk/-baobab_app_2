import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/data/offer_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_info_section.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offer_card_widget.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Le catalogue du commerçant, en carrousels.
///
/// Un carrousel par rayon (Plats, Chambres, Soins…) quand le commerçant en
/// déclare, sinon un seul. C'est la seule porte d'entrée vers l'achat sur
/// cette page : chaque offre mène à sa propre fiche, où l'on commande ou
/// l'on réserve. La fiche du commerce ne porte plus de bouton d'action, qui
/// obligeait à deviner ce qu'on allait y trouver avant d'avoir vu quoi que
/// ce soit.
class BusinessOffersSection extends StatefulWidget {
  final String businessId;

  const BusinessOffersSection({super.key, required this.businessId});

  @override
  State<BusinessOffersSection> createState() => _BusinessOffersSectionState();
}

class _BusinessOffersSectionState extends State<BusinessOffersSection> {
  List<Offer> _offers = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final catalogue = await OfferApiService().getCatalogue(widget.businessId);
    if (!mounted) return;
    setState(() {
      _offers = catalogue.offers;
      _loading = false;
    });
  }

  /// Regroupe les offres par rayon en conservant l'ordre du serveur : les
  /// offres datées d'abord, puis l'alphabétique.
  Map<String, List<Offer>> get _bySection {
    final grouped = <String, List<Offer>>{};
    for (final offer in _offers) {
      final section = (offer.section == null || offer.section!.isEmpty)
          ? 'Ce qu\'on y trouve'
          : offer.section!;
      grouped.putIfAbsent(section, () => []).add(offer);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _OffersSkeleton();

    // Rien à montrer : la section disparaît plutôt que d'annoncer un
    // catalogue inexistant.
    if (_offers.isEmpty) return const SizedBox.shrink();

    final sections = _bySection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in sections.entries) ...[
          // Le carrousel gère son propre titre et sa propre hauteur : c'est
          // le même composant que sur l'accueil, pour que le catalogue s'y
          // lise exactement pareil.
          OffersCarouselSection(title: entry.key, offers: entry.value),
          AppDimens.spacerMedium,
        ],
      ],
    );
  }
}

class _OffersSkeleton extends StatelessWidget {
  const _OffersSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BusinessSectionTitle('Ce qu\'on y trouve'),
          SizedBox(
            height: AppDimens.horizontalScrollHeight(
              context,
              0.30,
              min: 220,
              max: 280,
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) =>
                  const SizedBox(width: 190, child: OfferCardSkeleton()),
            ),
          ),
        ],
      ),
    );
  }
}
