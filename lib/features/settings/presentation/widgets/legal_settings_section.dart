import 'package:baobabe_0_2/core/widgets/custom_divider.dart';
import 'package:baobabe_0_2/features/settings/domain/legal/legal_documents.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// La section « Mentions légales » des paramètres : une entrée par texte
/// juridique, chacune ouvrant le texte lui-même.
///
/// La liste vient de [legalDocuments] : ajouter un document, c'est ajouter
/// une entrée ici sans toucher à cet écran.
class LegalSettingsSection extends StatelessWidget {
  const LegalSettingsSection({super.key});

  static IconData _icon(String slug) => switch (slug) {
    'confidentialite' => Icons.privacy_tip_outlined,
    'conditions' => Icons.description_outlined,
    _ => Icons.gavel_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return DetailSection(
      sectionTitle: 'Mentions légales',
      children: [
        for (var i = 0; i < legalDocuments.length; i++) ...[
          if (i > 0) const CustomDivider(),
          InfoTile(
            subtitle: legalDocuments[i].title,
            icon: _icon(legalDocuments[i].slug),
            onTap: () => context.pushNamed(
              'legal',
              pathParameters: {'slug': legalDocuments[i].slug},
            ),
          ),
        ],
      ],
    );
  }
}
