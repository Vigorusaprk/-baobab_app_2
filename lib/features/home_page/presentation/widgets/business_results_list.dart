import 'package:flutter/material.dart';
import '../../domain/entities/business_match.dart';
import 'business_card_placeholder.dart';

/// Liste verticale des business qui matchent (ou non) le budget.
/// Utilise le même conteneur vide que la version carte — à toi de
/// remplir le contenu (image, nom, prix, etc.) dans
/// `business_card_placeholder.dart`.
class BusinessResultsList extends StatelessWidget {
  final List<BusinessMatch> matches;
  final ValueChanged<BusinessMatch> onTap;

  const BusinessResultsList({
    Key? key,
    required this.matches,
    required this.onTap,
  }) : super(key: key);

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
          child: BusinessCardPlaceholder(onTap: () => onTap(match)),
        );
      },
    );
  }
}
