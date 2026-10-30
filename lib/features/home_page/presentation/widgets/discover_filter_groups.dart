import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_filters.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/offer_search_filters.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/filter_sheet_parts.dart';
import 'package:flutter/material.dart';

/// Regroupe les critères commerce et offre dans une seule feuille.
class _PriceBand {
  const _PriceBand(this.label, this.min, this.max);
  final String label;
  final double? min;
  final double? max;
}

class DiscoverFilterGroups extends StatelessWidget {
  const DiscoverFilterGroups({super.key, required this.filters, required this.onChanged});

  final DiscoverFilters filters;
  final ValueChanged<DiscoverFilters> onChanged;

  static const _prices = [
    _PriceBand('Moins de 10 \$', null, 10),
    _PriceBand('10 à 30 \$', 10, 30),
    _PriceBand('30 à 60 \$', 30, 60),
    _PriceBand('Plus de 60 \$', 60, null),
  ];
  static const _ratings = [(label: '3 et plus', value: 3.0), (label: '4 et plus', value: 4.0), (label: '4,5 et plus', value: 4.5)];

  @override
  Widget build(BuildContext context) => Column(children: [
    FilterSheetSection(title: 'Commerces', child: Wrap(spacing: AppDimens.small, children: [
      FilterSheetChip(label: 'Ouvert maintenant', icon: Icons.schedule_rounded, selected: filters.openNow, onSelected: (value) => onChanged(filters.copyWith(openNow: value))),
    ])),
    FilterSheetSection(title: 'Offres et services', child: Wrap(spacing: AppDimens.small, runSpacing: AppDimens.small, children: [
      for (final mode in Fulfilment.values)
        FilterSheetChip(label: mode.badge, selected: filters.fulfilment == mode, onSelected: (value) => onChanged(value ? filters.copyWith(fulfilment: mode) : filters.copyWith(clearFulfilment: true))),
    ])),
    FilterSheetSection(title: 'Budget', child: Wrap(spacing: AppDimens.small, runSpacing: AppDimens.small, children: [
      for (final band in _prices)
        FilterSheetChip(label: band.label, selected: filters.minPrice == band.min && filters.maxPrice == band.max, onSelected: (value) => onChanged(value ? filters.copyWith(clearPrice: true).copyWith(minPrice: band.min, maxPrice: band.max) : filters.copyWith(clearPrice: true))),
    ])),
    FilterSheetSection(title: 'Note minimale', child: Wrap(spacing: AppDimens.small, children: [
      for (final band in _ratings)
        FilterSheetChip(label: band.label, icon: Icons.star_rounded, selected: filters.minRating == band.value, onSelected: (value) => onChanged(value ? filters.copyWith(minRating: band.value) : filters.copyWith(clearRating: true))),
    ])),
    FilterSheetSection(title: 'Trier les offres', child: Wrap(spacing: AppDimens.small, runSpacing: AppDimens.small, children: [
      for (final sort in OfferSort.values)
        FilterSheetChip(label: sort.label, selected: filters.sort == sort, onSelected: (value) => onChanged(filters.copyWith(sort: value ? sort : OfferSort.relevance))),
    ])),
  ]);
}
