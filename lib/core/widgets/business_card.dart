import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'business_card_parts.dart';
part 'business_card_status.dart';

/// La carte d'un **commerce**, partout où l'application en montre un.
///
/// Elle répond en deux secondes à : qui, quoi, où, c'est ouvert ?, je peux y
/// faire quoi, c'est bien ? L'ancienne ligne — une lettre dans un carré, le
/// nom, une note — ne répondait qu'à « qui ». Elle disait « Ouvert » en dur,
/// affichait « 0,0 » pour un commerce sans avis, et n'avait pas la photo
/// alors que chaque commerce en a une.
///
/// **Une pièce, deux formes.** [BusinessCard.tile] — photo 16:9 en haut,
/// pour l'accueil et la grille d'Explorer ; [BusinessCard.row] — vignette à
/// gauche, pour les listes longues. Même hiérarchie d'information dans les
/// deux, seule la mise en page change : deux dessins d'un même objet
/// feraient deux applications.
///
/// Ce que la carte affirme vient du serveur (vue `business_card`) : ouvert
/// ou fermé à l'heure de Kinshasa, ce qu'on peut y faire. Quand le serveur
/// ne l'a pas dit, la carte se tait plutôt que de deviner.
class BusinessCard extends StatelessWidget {
  const BusinessCard.tile({
    super.key,
    required this.business,
    required this.onTap,
    this.featuredOffer,
  }) : _layout = _Layout.tile;

  const BusinessCard.row({
    super.key,
    required this.business,
    required this.onTap,
    this.featuredOffer,
  }) : _layout = _Layout.row;

  final Business business;
  final VoidCallback onTap;

  /// Le nom de l'offre qu'une campagne visait, s'il y en a une : la vedette
  /// reste le commerce, mais la carte dit ce qu'il pousse.
  final String? featuredOffer;

  final _Layout _layout;

  /// La photo d'une tuile : 16:9, pour donner de la place à ce qu'on met en
  /// avant. Partagée avec le squelette pour que la page ne saute pas.
  static const double tileAspectRatio = 16 / 9;

  /// La vignette d'une ligne.
  static const double rowThumb = 72;

  /// Le liseré entre le bord de la carte et la photo : la photo ne touche pas
  /// le bord, elle est posée sur la carte. Partagé avec le squelette.
  static const double frame = AppDimens.tiny;

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
            padding: const EdgeInsets.all(frame),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimens.cardBorderRadius - frame,
              ),
              child: switch (_layout) {
                _Layout.tile => _Tile(
                  business: business,
                  featuredOffer: featuredOffer,
                ),
                _Layout.row => _RowLayout(
                  business: business,
                  featuredOffer: featuredOffer,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

enum _Layout { tile, row }

/// Squelette d'une [BusinessCard], aux mêmes dimensions que la vraie : un
/// squelette plus haut ou plus court fait sauter la page au remplacement.
class BusinessCardSkeleton extends StatelessWidget {
  const BusinessCardSkeleton.tile({super.key}) : _layout = _Layout.tile;
  const BusinessCardSkeleton.row({super.key}) : _layout = _Layout.row;

  final _Layout _layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Widget body = switch (_layout) {
      _Layout.tile => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AspectRatio(
            aspectRatio: BusinessCard.tileAspectRatio,
            child: Bone(width: double.infinity, height: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.allPadding12Number),
            child: _SkeletonText(theme: theme),
          ),
        ],
      ),
      _Layout.row => Padding(
        padding: const EdgeInsets.all(AppDimens.allPadding12Number),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Bone(
              width: BusinessCard.rowThumb,
              height: BusinessCard.rowThumb,
              uniRadius: AppDimens.radius12,
            ),
            AppDimens.spacerMediumWidth,
            Expanded(child: _SkeletonText(theme: theme)),
          ],
        ),
      ),
    };

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppDimens.cardBorderRadiusAll,
      ),
      clipBehavior: Clip.antiAlias,
      // Le même liseré que la carte : sans lui, l'os de la photo serait plus
      // large que la photo, donc plus haut, et la page sauterait.
      child: Padding(
        padding: const EdgeInsets.all(BusinessCard.frame),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AppDimens.cardBorderRadius - BusinessCard.frame,
          ),
          child: body,
        ),
      ),
    );
  }
}

class _SkeletonText extends StatelessWidget {
  const _SkeletonText({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Bone.text(width: 150, style: theme.textTheme.titleSmall!),
        AppDimens.spacerMini,
        Bone.text(width: 110, style: theme.textTheme.bodySmall!),
        AppDimens.spacerMini,
        Bone.text(width: 170, style: theme.textTheme.bodySmall!),
        AppDimens.spacerSmall,
        const Row(
          children: [
            Bone(width: 74, height: 22, uniRadius: AppDimens.radius8),
            AppDimens.spacerSmallWidth,
            Bone(width: 66, height: 22, uniRadius: AppDimens.radius8),
          ],
        ),
      ],
    );
  }
}
