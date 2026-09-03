import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Un avis.
///
/// C'était une carte : avatar rond de 40 px, nom en gras, étoiles, date, et
/// le commentaire dessous. Trois avis de suite donnaient trois blocs à lire
/// séparément, et l'avatar — souvent absent, donc remplacé par une silhouette
/// grise — occupait la place du texte sans rien apprendre.
///
/// Ici l'avis suit un **rail** : un filet vertical à gauche, le nom, la note
/// et la date sur une ligne, le propos dessous. Le premier avis porte le rail
/// en couleur d'action, les suivants en teinte douce — ce qui donne un ordre
/// de lecture sans numéroter.
class ReviewListItem extends StatelessWidget {
  const ReviewListItem({super.key, required this.review, this.accent = false});

  final Review review;

  /// Le premier de la liste. Son rail est vif.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.medium),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 2,
              decoration: BoxDecoration(
                color: accent ? scheme.primary : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppDimens.spacerMediumWidth,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          review.userName ?? 'Anonyme',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppDimens.spacerSmallWidth,
                      _Stars(rating: review.rating),
                      const Spacer(),
                      Text(
                        _when(review.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (review.comment != null &&
                      review.comment!.trim().isNotEmpty) ...[
                    AppDimens.spacerMini,
                    Text(
                      review.comment!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.55,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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

/// Les étoiles de la note, en petit et sans interaction : ici on lit une
/// note, on n'en pose pas.
class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    final color = OtherTheme.of(context).rating;
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 12,
            color: color,
          ),
      ],
    );
  }
}
