import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:baobabe_0_2/features/settings/domain/legal/legal_documents.dart';
import 'package:flutter/material.dart';

/// Un texte juridique, à lire : mentions légales, confidentialité,
/// conditions d'utilisation.
///
/// Une page de lecture, rien d'autre — pas de bouton « J'accepte », pas de
/// case à cocher : on ne demande pas d'accepter ce qu'on vient consulter.
/// Le texte est **dans** l'application : il se lit sans réseau et sans
/// quitter l'écran.
class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomOtherAppBar(title: document.title),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: AppDimens.appPadding.copyWith(
            top: AppDimens.small,
            bottom: AppDimens.large,
          ),
          children: [
            Text(
              'Dernière mise à jour : ${document.updatedOn}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            AppDimens.spacerMedium,
            Text(
              document.intro,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            for (final section in document.sections) ...[
              AppDimens.spacerLarge,
              Text(
                section.title,
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.justify,
              ),
              for (final paragraph in section.paragraphs) ...[
                AppDimens.spacerSmall,
                Text(
                  paragraph,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// La page derrière `/legal/:slug`. Un `slug` inconnu — une vieille adresse,
/// une faute de frappe sur le web — donne un message, pas une exception.
class LegalRoutePage extends StatelessWidget {
  const LegalRoutePage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final document = legalDocumentBySlug(slug);
    if (document != null) return LegalPage(document: document);

    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomOtherAppBar(title: 'Mentions légales'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.large),
          child: Text(
            "Ce document n'existe pas.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
