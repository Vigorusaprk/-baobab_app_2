import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/offer_search_filters.dart';
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
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Filtrer les offres',
                style: theme.textTheme.titleLarge,
              ),
            ),
            if (_draft.hasFacets)
              TextButton(
                onPressed: () =>
                    setState(() => _draft = _draft.clearedFacets()),
                child: Text(
                  'Tout effacer',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
        AppDimens.spacerSmall,

        _Section(
          title: 'Ce que je veux en faire',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              for (final f in Fulfilment.values)
                _Chip(
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

        _Section(
          title: 'Budget',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              for (final band in _priceBands)
                _Chip(
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

        _Section(
          title: 'Note minimale',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              for (final band in _ratingBands)
                _Chip(
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

        _Section(
          title: 'Trier par',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              for (final sort in OfferSort.values)
                _Chip(
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
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context, _draft),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: AppDimens.medium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius16),
              ),
            ),
            child: const Text('Voir les offres'),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          AppDimens.spacerSmall,
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      selected: selected,
      onSelected: onSelected,
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 16,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
      label: Text(label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusSmallButton),
      ),
    );
  }
}
