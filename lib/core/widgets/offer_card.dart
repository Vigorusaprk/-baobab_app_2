import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// La carte d'une **offre**, partout où l'application en montre une.
///
/// Une carte blanche à marge intérieure, bâtie en deux blocs franchement
/// séparés : la photo en haut, le texte en dessous sur l'aplat de la carte.
///
/// Il n'y a **pas de fondu** entre les deux, et c'est un choix arrêté après
/// l'avoir essayé quatre fois — bande masquée par un dégradé, `BackdropFilter`,
/// dégradé exprimé en fractions de carte, fondu solidaire du bloc de texte.
/// Chaque version coûtait de la hauteur de photo, et aucune ne rendait la
/// carte plus lisible qu'une séparation nette. La photo montre le produit, le
/// texte le nomme ; la frontière entre les deux n'a pas besoin d'être adoucie.
///
/// Le texte reposant sur un aplat opaque, son contraste est celui du thème —
/// 16,7:1 pour le nom, 7,9:1 pour « chez X », 14,7:1 pour le prix — et ne
/// dépend jamais du visuel.
///
/// Pas de bouton dans la carte : la carte entière est le bouton. En ajouter un
/// créerait une petite cible collée à un geste de défilement, et une offre en
/// boutique n'a de toute façon aucune action à proposer.
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onTap,
    this.sponsored = false,
  });

  final Offer offer;
  final VoidCallback onTap;

  /// L'offre est-elle poussée par une campagne payée ? Le dire est une
  /// obligation, pas une option : une mise en avant qui ne se distingue pas
  /// d'un classement fait passer de la publicité pour du mérite.
  final bool sponsored;

  /// La marge blanche autour de la photo.
  static const double _frame = AppDimens.tiny;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PressEffect(
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppDimens.cardBorderRadiusAll,
        clipBehavior: Clip.antiAlias,
        elevation: AppDimens.elevationDefault,
        shadowColor: scheme.onSurface.withValues(alpha: 0.10),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(_frame),
            child: ClipRRect(
              // Rayon extérieur moins la marge : sans cette soustraction les deux
              // arrondis ne sont pas concentriques, et le liseré blanc paraît
              // plus épais dans les coins que sur les côtés.
              borderRadius: BorderRadius.circular(
                AppDimens.cardBorderRadius - _frame,
              ),
              child: Column(
                children: [
                  // La photo prend toute la place que le texte ne réclame pas.
                  Expanded(child: _Photo(offer: offer, sponsored: sponsored)),
                  ColoredBox(
                    color: scheme.surfaceContainerLowest,
                    child: _Content(offer: offer),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// La photo, et les deux badges posés dessus.
class _Photo extends StatelessWidget {
  const _Photo({required this.offer, this.sponsored = false});

  final Offer offer;
  final bool sponsored;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteImage(url: offer.displayImage),
          // Les badges sont posés, pas empilés : sur un écran court la zone
          // photo peut devenir plus basse que les deux badges réunis, et une
          // colonne déborderait. Ils se rapprochent alors au lieu de lever.
          Positioned(
            top: AppDimens.small,
            left: AppDimens.small,
            child: _Badge(
              // Dire l'action possible dès la carte évite d'ouvrir une fiche
              // pour découvrir qu'on ne peut que réserver — ou qu'il faut
              // simplement passer en boutique.
              label: offer.fulfilment.badge,
              color: offer.isOrderable
                  ? Theme.of(context).colorScheme.secondary
                  : offer.isBookable
                  ? Theme.of(context).colorScheme.primary
                  : OtherTheme.of(context).onWarningContainer,
            ),
          ),
          // En bas à droite. Essayé en haut à droite d'abord : sur une carte
          // de rail de 190 px, « À réserver » et « Sponsorisé » se
          // rejoignaient au milieu et les deux devenaient illisibles. Les
          // trois coins occupés ne se touchent plus — mode en haut à gauche,
          // date en bas à gauche, mention payée en bas à droite.
          if (sponsored)
            Positioned(
              bottom: AppDimens.small,
              right: AppDimens.small,
              child: _Badge(
                label: 'Sponsorisé',
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          if (offer.startsAt != null)
            Positioned(
              bottom: AppDimens.small,
              left: AppDimens.small,
              child: _Badge(
                label: DateFormat('dd/MM').format(offer.startsAt!.toLocal()),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
        ],
      ),
    );
  }
}

/// Le texte de la carte, sur l'aplat de la carte.
///
/// Nom, puis chez qui, puis une ligne qui oppose le prix à la note. C'est ce
/// qui permet de savoir d'un coup d'œil si l'on regarde une chose à acheter ou
/// un endroit où aller.
class _Content extends StatelessWidget {
  const _Content({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.allPadding12Number,
        AppDimens.small,
        AppDimens.allPadding12Number,
        AppDimens.allPadding12Number,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (offer.businessName != null) ...[
            const SizedBox(height: 2),
            Text(
              'chez ${offer.businessName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: AppDimens.small),
          Row(
            children: [
              Expanded(
                child: Text(
                  offer.isFree
                      ? 'Sur demande'
                      : '${offer.price.toStringAsFixed(0)} \$',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
              if (offer.reviewCount > 0) ...[
                Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: OtherTheme.of(context).rating,
                ),
                Text(
                  offer.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.small,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Squelette d'une [OfferCard], à envelopper dans un `Skeletonizer`.
///
/// Il reprend les deux blocs — photo en haut, texte en bas — pour que la page
/// ne saute pas au moment où les données arrivent.
class OfferCardSkeleton extends StatelessWidget {
  const OfferCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surfaceContainerLowest;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppDimens.cardBorderRadiusAll,
      ),
      padding: const EdgeInsets.all(OfferCard._frame),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimens.cardBorderRadius - OfferCard._frame,
        ),
        child: Column(
          children: [
            const Expanded(
              child: Bone(width: double.infinity, height: double.infinity),
            ),
            ColoredBox(
              color: surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.allPadding12Number,
                  AppDimens.small,
                  AppDimens.allPadding12Number,
                  AppDimens.allPadding12Number,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(
                      words: 2,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                    const SizedBox(height: 6),
                    Bone.text(
                      width: 80,
                      style: Theme.of(context).textTheme.bodySmall!,
                    ),
                    const SizedBox(height: AppDimens.small),
                    Bone.text(
                      width: 50,
                      style: Theme.of(context).textTheme.bodyMedium!,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
