import 'dart:ui';

import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// La carte d'une **offre**, partout où l'application en montre une.
///
/// Une carte blanche à marge intérieure, dans laquelle la photo est posée
/// avec ses propres coins arrondis. Le texte se pose sur le bas de la photo,
/// rendu lisible par un flou qui monte progressivement et un voile clair.
///
/// Le voile est dosé pour que chaque ligne de texte atteigne 4,5:1 à la
/// hauteur où elle se trouve, sur une photo entièrement noire — voir [_Scrim]
/// pour le détail du calcul.
///
/// Pas de bouton dans la carte : la carte entière est le bouton. En ajouter
/// un créerait une petite cible collée à un geste de défilement, et une offre
/// en boutique n'a de toute façon aucune action à proposer.
class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, required this.onTap});

  final Offer offer;
  final VoidCallback onTap;

  /// La marge blanche autour de la photo.
  static const double _frame = AppDimens.tiny;

  /// Opacité du voile tout en bas de la carte. Les paliers intermédiaires
  /// s'en déduisent — voir [_Scrim], où ils sont calculés.
  static const double _scrimAlpha = 0.96;

  static const double _blurSigma = 16;

  /// Les paliers du voile, et la part de [_scrimAlpha] atteinte à chacun.
  ///
  /// Exposés pour que `test/offer_card_test.dart` recalcule les contrastes
  /// depuis ces valeurs-ci, plutôt que depuis une copie qui finirait par
  /// diverger. C'est ce qui a laissé passer le défaut : le calcul avait été
  /// fait une fois, à la main, à la mauvaise hauteur.
  @visibleForTesting
  static const List<double> scrimStops = [0.18, 0.46, 0.68, 1.0];

  @visibleForTesting
  static const List<double> scrimAlphaFactors = [0, 0.583, 0.875, 1.0];

  /// L'opacité du voile à la hauteur [t] (0 en haut, 1 en bas).
  @visibleForTesting
  static double scrimAlphaAt(double t) {
    for (var i = 0; i < scrimStops.length - 1; i++) {
      if (t <= scrimStops[i]) break;
      if (t <= scrimStops[i + 1]) {
        final f = (t - scrimStops[i]) / (scrimStops[i + 1] - scrimStops[i]);
        final factor =
            scrimAlphaFactors[i] +
            (scrimAlphaFactors[i + 1] - scrimAlphaFactors[i]) * f;
        return _scrimAlpha * factor;
      }
    }
    return t <= scrimStops.first ? 0 : _scrimAlpha;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: AppDimens.cardBorderRadiusAll,
      clipBehavior: Clip.antiAlias,
      elevation: AppDimens.elevationDefault,
      shadowColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.10),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(_frame),
          child: ClipRRect(
            // Rayon extérieur moins la marge : sans cette soustraction les
            // deux arrondis ne sont pas concentriques, et le liseré blanc
            // paraît plus épais dans les coins que sur les côtés.
            borderRadius: BorderRadius.circular(
              AppDimens.cardBorderRadius - _frame,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RemoteImage(url: offer.displayImage),
                _ProgressiveBlur(url: offer.displayImage),
                const _Scrim(alpha: _scrimAlpha),
                Positioned(
                  top: AppDimens.small,
                  left: AppDimens.small,
                  child: _Badge(
                    // Dire l'action possible dès la carte évite d'ouvrir une
                    // fiche pour découvrir qu'on ne peut que réserver — ou
                    // qu'il faut simplement passer en boutique.
                    label: offer.fulfilment.badge,
                    color: offer.isOrderable
                        ? Theme.of(context).colorScheme.secondary
                        : offer.isBookable
                        ? Theme.of(context).colorScheme.primary
                        : OtherTheme.of(context).onWarningContainer,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _Content(offer: offer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La copie floutée de la photo, dont le flou naît en haut et s'installe en
/// bas.
///
/// On ne passe pas par un `BackdropFilter` : ce qu'il y a derrière le voile,
/// c'est la photo de la carte elle-même. Flouter une copie coûte bien moins
/// cher que de faire relire la scène au moteur de rendu — et ces cartes
/// défilent par paquets sur le web.
///
/// **Aucun découpage.** Une première version ne floutait qu'une bande basse,
/// masquée par un dégradé calculé sur l'image entière : le fondu se terminait
/// donc au-dessus de la bande, et le découpage tranchait net une image déjà
/// floutée aux trois quarts — la frontière se voyait comme un trait. La copie
/// couvre désormais toute la photo, et le dégradé est seul à décider où le
/// flou apparaît. Sans découpage, il n'y a plus de bord possible.
class _ProgressiveBlur extends StatelessWidget {
  const _ProgressiveBlur({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    // `BlendMode.dstIn` ne lit que le canal alpha du masque : la teinte
    // choisie ici n'est jamais peinte. On la prend quand même dans le thème
    // plutôt qu'en dur — une valeur littérale laisserait croire à une couleur
    // qu'un thème sombre devrait suivre.
    final mask = Theme.of(context).colorScheme.onSurface;

    return Positioned.fill(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [mask.withValues(alpha: 0), mask],
          // Une rampe longue : le flou met la moitié de la carte à
          // s'installer, ce qui est ce qui le rend invisible en tant que
          // frontière.
          stops: const [0.25, 0.95],
        ).createShader(rect),
        child: ImageFiltered(
          // `decal` empêche les bords de se répéter dans le flou, ce qui
          // barbouillerait les côtés de la photo.
          imageFilter: ImageFilter.blur(
            sigmaX: OfferCard._blurSigma,
            sigmaY: OfferCard._blurSigma,
            tileMode: TileMode.decal,
          ),
          child: RemoteImage(url: url),
        ),
      ),
    );
  }
}

/// Le voile clair qui garantit la lisibilité quelle que soit la photo.
///
/// Les paliers ne sont pas choisis à l'œil : ils sont calculés pour que
/// **chaque ligne de texte** atteigne 4,5:1 à la hauteur où elle se trouve,
/// dans le pire cas — une photo entièrement noire sous le voile.
///
/// Une version précédente n'avait été vérifiée qu'en bas de carte, où le
/// voile culmine. Mais le nom se trouve à mi-hauteur, où le voile n'était
/// alors qu'à 0,28 : le titre sortait à **1,79:1** sur une photo claire, et se
/// lisait mal. Les paliers ci-dessous couvrent les trois hauteurs :
///
/// | ligne          | hauteur | voile | contraste |
/// |----------------|---------|-------|-----------|
/// | nom            | 0,46    | 0,56  | 5,15:1    |
/// | « chez X »     | 0,66    | 0,81  | 5,09:1    |
/// | prix et note   | 0,80    | 0,89  | 11,3:1    |
///
/// « chez X » est la ligne la plus exigeante : c'est la plus pâle de la
/// palette, elle réclame à elle seule un voile à 0,77. Déplacer du texte plus
/// haut dans la carte, ou éclaircir une de ces couleurs, demande de refaire
/// ce calcul.
class _Scrim extends StatelessWidget {
  const _Scrim({required this.alpha});

  /// Opacité atteinte tout en bas.
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surfaceContainerLowest;
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                for (final factor in OfferCard.scrimAlphaFactors)
                  surface.withValues(alpha: alpha * factor),
              ],
              stops: OfferCard.scrimStops,
            ),
          ),
        ),
      ),
    );
  }
}

/// Le texte de la carte : la disposition d'origine, posée sur la photo.
///
/// Nom, puis chez qui, puis une ligne qui oppose le prix à la note. C'est ce
/// qui permet de savoir d'un coup d'œil si l'on regarde une chose à acheter
/// ou un endroit où aller.
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
          // La date fermait le bas de la photo dans la carte d'origine. Le bas
          // étant maintenant le texte, elle se pose juste au-dessus du nom —
          // au même endroit à l'œil, sur la partie encore nette.
          if (offer.startsAt != null) ...[
            _Badge(
              label: DateFormat('dd/MM').format(offer.startsAt!.toLocal()),
              color: scheme.onSurface,
            ),
            const SizedBox(height: 6),
          ],
          Text(
            offer.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (offer.businessName != null) ...[
            const SizedBox(height: 2),
            Text(
              'chez ${offer.businessName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
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
                    fontWeight: FontWeight.w600,
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
                  style: Theme.of(context).textTheme.bodySmall,
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Squelette d'une [OfferCard], à envelopper dans un `Skeletonizer`.
///
/// Il reprend le cadre blanc, la photo et les trois blocs de texte, pour que
/// la page ne saute pas au moment où les données arrivent.
class OfferCardSkeleton extends StatelessWidget {
  const OfferCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: AppDimens.cardBorderRadiusAll,
      ),
      padding: const EdgeInsets.all(OfferCard._frame),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimens.cardBorderRadius - OfferCard._frame,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Bone(width: double.infinity, height: double.infinity),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
            ),
          ],
        ),
      ),
    );
  }
}
