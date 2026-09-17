import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/offer_search_filters.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/filter_sheet_parts.dart';
import 'package:flutter/material.dart';

/// Une fourchette de prix proposée d'un geste.
///
/// Des tranches plutôt qu'un curseur : un curseur demande une borne haute
/// arbitraire — 200 \$ ? 500 ? — et oblige à viser au doigt. Les tranches
/// disent la même chose en un mot, et « Plus de 60 \$ » n'a pas de plafond à
/// inventer.
class _PriceBand {
  const _PriceBand(this.label, this.min, this.max);
  final String label;
  final double? min;
  final double? max;

  bool matches(OfferSearchFilters f) => f.minPrice == min && f.maxPrice == max;
}

const _priceBands = [
  _PriceBand('Moins de 10 \$', null, 10),
  _PriceBand('10 à 30 \$', 10, 30),
  _PriceBand('30 à 60 \$', 30, 60),
  _PriceBand('Plus de 60 \$', 60, null),
];

const _ratingBands = [
  (label: '3 et plus', value: 3.0),
  (label: '4 et plus', value: 4.0),
  (label: '4,5 et plus', value: 4.5),
];

/// Ouvre le panneau de filtres et rend les critères choisis.
///
/// Rend `null` si l'utilisateur referme sans valider : l'appelant garde alors
/// ses filtres courants.
Future<OfferSearchFilters?> showExploreFiltersSheet(
  BuildContext context,
  OfferSearchFilters current,
) {
  return showCustomBottomSheet<OfferSearchFilters>(
    context: context,
    child: _ExploreFilters(initial: current),
  );
}

class _ExploreFilters extends StatefulWidget {
  const _ExploreFilters({required this.initial});

  final OfferSearchFilters initial;

  @override
  State<_ExploreFilters> createState() => _ExploreFiltersState();
}

class _ExploreFiltersState extends State<_ExploreFilters> {
  late OfferSearchFilters _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSheetTitle(
          title: 'Filtrer les offres',
          canClear: _draft.hasFacets,
          onClear: () => setState(() => _draft = _draft.clearedFacets()),
        ),
        AppDimens.spacerSmall,

        FilterSheetSection(
          title: 'Ce que je veux en faire',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              for (final f in Fulfilment.values)
                FilterSheetChip(
                  label: f.badge,
                  selected: _draft.fulfilment == f,
                  onSelected: (on) => setState(() {
                    _draft = on
                        ? _draft.copyWith(fulfilment: f)
                        : _draft.copyWith(clearFulfilment: true);
                  }),
                ),
            ],
          ),
        ),

        FilterSheetSection(
          title: 'Budget',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              for (final band in _priceBands)
                FilterSheetChip(
                  label: band.label,
                  selected: band.matches(_draft),
                  onSelected: (on) => setState(() {
                    _draft = on
                        ? _draft
                              .copyWith(clearPrice: true)
                              .copyWith(minPrice: band.min, maxPrice: band.max)
                        : _draft.copyWith(clearPrice: true);
                  }),
                ),
            ],
          ),
        ),

        FilterSheetSection(
          title: 'Note minimale',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              for (final band in _ratingBands)
                FilterSheetChip(
                  label: band.label,
                  icon: Icons.star_rounded,
                  selected: _draft.minRating == band.value,
                  onSelected: (on) => setState(() {
                    _draft = on
                        ? _draft.copyWith(minRating: band.value)
                        : _draft.copyWith(clearRating: true);
                  }),
                ),
            ],
          ),
        ),

        FilterSheetSection(
          title: 'Trier par',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              for (final sort in OfferSort.values)
                FilterSheetChip(
                  label: sort.label,
                  selected: _draft.sort == sort,
                  // Un tri est toujours actif : le déselectionner n'a pas de
                  // sens, on retombe sur la pertinence.
                  onSelected: (on) => setState(() {
                    _draft = _draft.copyWith(
                      sort: on ? sort : OfferSort.relevance,
                    );
                  }),
                ),
            ],
          ),
        ),

        AppDimens.spacerMedium,
        CustomButton(
          text: 'Voir les offres',
          onPressed: () => Navigator.pop(context, _draft),
        ),
      ],
    );
  }
}
