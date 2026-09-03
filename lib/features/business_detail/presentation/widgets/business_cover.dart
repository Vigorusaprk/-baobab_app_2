import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// La photo du commerce, et les deux gestes qui se posent dessus.
///
/// C'était une barre pliante de 350 px qui, en se pliant, faisait disparaître
/// la photo derrière un dégradé de deux couleurs de marque puis ramenait le
/// nom du commerce au centre : trois états pour une seule information, et un
/// dégradé qui ne disait rien. La photo fait maintenant 210 px, elle ne
/// change pas d'apparence, et le nom vit dans la feuille qui la recouvre —
/// donc à sa place définitive dès le premier pixel de défilement.
///
/// Elle **reste une barre épinglée**, pour une raison qui n'a rien à voir
/// avec la photo : la page est bord à bord, et sans bandeau opaque en haut,
/// « Horaires d'ouverture » se peignait par-dessus l'heure du système en
/// défilant. Repliée, il ne reste que ce bandeau et les deux gestes.
class BusinessCover extends StatelessWidget {
  const BusinessCover({
    super.key,
    required this.business,
    required this.uiBusiness,
  });

  final Business business;
  final UIBusiness uiBusiness;

  /// Assez pour situer le commerce, pas assez pour repousser ses offres sous
  /// la ligne de flottaison.
  static const double height = 210;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      // `expandedHeight` comprend la barre d'état : sans l'ajouter, la photo
      // perdait la quarantaine de pixels qu'elle lui prête.
      expandedHeight: height + MediaQuery.paddingOf(context).top,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leadingWidth: AppDimens.touchTarget + AppDimens.medium,
      // `_Round` est indispensable : une barre étire son `leading` sur toute
      // la largeur qu'elle lui réserve, et le disque devenait un ovale.
      leading: const _Round(
        padding: EdgeInsets.only(left: AppDimens.appPaddingValue),
        child: _BackButton(),
      ),
      // Pas de cœur : rien ne mémorise un favori côté serveur, et un cœur
      // qui ne retient rien est une promesse non tenue.
      actions: [
        _Round(
          padding: const EdgeInsets.only(right: AppDimens.appPaddingValue),
          child: CustomIconButton(
            onPressed: _share,
            tooltip: 'Partager ce commerce',
            icon: Icons.ios_share_rounded,
            circle: true,
            iconSize: AppDimens.medium + 2,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // `none` : la photo **ne bouge pas**. Le contenu passe par-dessus,
        // ce qui donne le sentiment que la feuille glisse sur l'image plutôt
        // que l'image ne s'échappe vers le haut.
        collapseMode: CollapseMode.none,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'business-image-${business.id}',
              child: business.bgImg.isNotEmpty
                  ? RemoteImage(url: business.bgImg, fallback: _Fallback(uiBusiness))
                  : _Fallback(uiBusiness),
            ),
            // Le bord à bord fait passer la photo **sous** la barre d'état.
            // Les icônes du système sont sombres dans toute l'application :
            // le voile est donc **clair**, pour les tenir lisibles sur une
            // photo sombre sans les inverser pour un seul écran.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.paddingOf(context).top + AppDimens.large,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        scheme.surfaceContainerLowest.withValues(alpha: 0.72),
                        scheme.surfaceContainerLowest.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Un partage **texte**. Il n'existe pas d'adresse web par commerce : on
  /// partage donc ce qu'on sait — le nom et l'adresse — plutôt qu'un lien
  /// qui ne mènerait nulle part.
  Future<void> _share() => SharePlus.instance.share(
    ShareParams(
      text: '${business.name}\n${business.address}\n\nVu sur Baobabe.',
      subject: business.name,
    ),
  );
}

/// Un disque qui reste un disque.
///
/// Une barre d'application étire ce qu'on lui donne en `leading` et en
/// `actions` : sans cette contrainte carrée, le bouton de retour s'affichait
/// en ovale.
class _Round extends StatelessWidget {
  const _Round({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: SizedBox.square(
          dimension: AppDimens.touchTarget,
          child: child,
        ),
      ),
    );
  }
}

/// Le retour : la route parente, ou l'accueil quand on est arrivé par lien
/// direct.
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: () {
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else {
          router.go('/home');
        }
      },
      tooltip: 'Retour',
      icon: Icons.arrow_back_rounded,
      circle: true,
      iconSize: AppDimens.medium + 2,
    );
  }
}

/// La couleur de la catégorie, quand il n'y a pas de photo — ou qu'elle ne
/// charge pas.
class _Fallback extends StatelessWidget {
  const _Fallback(this.uiBusiness);

  final UIBusiness uiBusiness;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: uiBusiness.categoryColor(context));
}
