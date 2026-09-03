import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Un avis, où qu'on l'affiche.
///
/// Il en existait deux formes : une carte dans la fiche du commerce (avatar
/// rond de 40 px, nom en gras, étoiles, date, commentaire dessous) et une
/// autre dans la fiche de l'offre. Trois avis de suite donnaient trois blocs
/// à lire séparément, et l'avatar — souvent absent, donc remplacé par une
/// silhouette grise — occupait la place du texte sans rien apprendre.
///
/// Ici l'avis suit un **rail** : un filet vertical à gauche, le nom, la note
/// et la date sur une ligne, le propos dessous. Le premier avis porte le rail
/// en couleur d'action, les suivants en teinte douce — ce qui donne un ordre
/// de lecture sans numéroter.
///
/// Il ne connaît **aucune entité** : chaque appelant lui passe ce qu'il a. Un
/// avis de commerce et un avis d'offre ne sont pas la même classe en base, et
/// c'était la raison pour laquelle il y avait deux composants.
class CustomReviewItem extends StatelessWidget {
  const CustomReviewItem({
    super.key,
    required this.author,
    required this.rating,
    required this.createdAt,
    this.comment,
    this.accent = false,
  });

  /// `null` ou vide devient « Anonyme » : un avis sans nom reste un avis.
  final String? author;

  /// La note, de 0 à 5. Les demies sont dessinées.
  final double rating;

  final DateTime createdAt;
  final String? comment;

  /// Le premier de la liste. Son rail est vif.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = comment?.trim();

    // Le rail est une **bordure**, pas une colonne voisine étirée. Un frère
    // en `CrossAxisAlignment.stretch` réclame un `IntrinsicHeight`, or le
    // propos se mesure avec un `LayoutBuilder` pour savoir s'il dépasse —
    // et un `LayoutBuilder` ne sait pas répondre à une mesure intrinsèque.
    // Une bordure gauche prend la hauteur du contenu sans rien mesurer.
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.medium),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: accent ? scheme.primary : scheme.primaryContainer,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.only(left: AppDimens.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    (author == null || author!.trim().isEmpty)
                        ? 'Anonyme'
                        : author!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppDimens.spacerSmallWidth,
                ReadOnlyStars(rating: rating, size: 12),
                const Spacer(),
                Text(
                  _when(createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (text != null && text.isNotEmpty) ...[
              AppDimens.spacerMini,
              _Comment(text: text, onExpand: () => _open(context, text)),
            ],
          ],
        ),
      ),
    );
  }

  /// Le propos entier, dans une feuille.
  ///
  /// Une liste d'avis se parcourt : un avis de dix lignes au milieu repousse
  /// les suivants hors de l'écran et fait croire qu'il n'y en a qu'un.
  void _open(BuildContext context, String text) {
    final name = (author == null || author!.trim().isEmpty)
        ? 'Anonyme'
        : author!;

    showCustomBottomSheet<void>(
      context: context,
      title: 'Avis de $name',
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ReadOnlyStars(rating: rating, size: AppDimens.medium),
                  AppDimens.spacerSmallWidth,
                  Text(
                    _when(createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              AppDimens.spacerMedium,
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Une date d'avis se lit en repères, pas en chiffres : « hier » situe, le
  /// 24/08 demande un calcul.
  static String _when(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return "aujourd'hui";
    if (days == 1) return 'hier';
    if (days < 7) return 'il y a $days jours';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }
}

/// Le propos, **deux lignes au plus**.
///
/// Un avis bavard occupait autant de place que dix avis courts. « Voir plus »
/// n'apparaît que s'il y a vraiment quelque chose de coupé : la mesure est
/// faite avec la largeur réelle disponible, pas devinée à un nombre de
/// caractères.
class _Comment extends StatelessWidget {
  const _Comment({required this.text, required this.onExpand});

  final String text;
  final VoidCallback onExpand;

  static const int _maxLines = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.55,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: _maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              maxLines: _maxLines,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
            if (painter.didExceedMaxLines)
              // Un bouton de texte sans retrait : il prolonge le propos, il
              // n'ouvre pas une action.
              TextButton(
                onPressed: onExpand,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, AppDimens.large + 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  'Voir plus',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
