import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/business_match.dart';
import 'business_list_row.dart';

/// Les commerces retenus par la recherche selon le budget.
///
/// La liste réutilise [BusinessListRow] — la même ligne que « Voir tout » et
/// que les commerces populaires : un commerce se présente partout de la même
/// façon. Le prix moyen, lui, est propre à cet écran : c'est la réponse à la
/// question qu'on vient d'y poser, il occupe donc le bout de ligne.
class BusinessResultsList extends StatelessWidget {
  final List<BusinessMatch> matches;
  final ValueChanged<BusinessMatch> onTap;

  const BusinessResultsList({
    super.key,
    required this.matches,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aucun commerce dans ce budget. Essayez un montant plus élevé.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: BusinessListRow(
            uiBusiness: UIBusiness(match.business),
            onTap: () => onTap(match),
            trailing: _AveragePrice(match: match),
          ),
        );
      },
    );
  }
}

/// Le prix moyen du commerce, et s'il tient dans le budget demandé.
///
/// Un commerce sans `menu_items` ni `rooms` n'a pas de prix moyen : on le dit
/// plutôt que d'afficher un zéro qui se lirait comme « gratuit ».
class _AveragePrice extends StatelessWidget {
  const _AveragePrice({required this.match});

  final BusinessMatch match;

  @override
  Widget build(BuildContext context) {
    final price = match.averagePrice;
    final scheme = Theme.of(context).colorScheme;

    if (price == null) {
      return Text(
        'Prix inconnu',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${price.toStringAsFixed(0)} \$',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: match.matchesBudget ? scheme.primary : scheme.onSurface,
          ),
        ),
        Text(
          'en moyenne',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
