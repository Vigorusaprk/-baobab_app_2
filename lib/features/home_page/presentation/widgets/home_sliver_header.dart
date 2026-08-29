import 'dart:ui' show lerpDouble;

import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

/// En-tête collant de l'accueil : salutation + barre de recherche +
/// catégories.
///
/// Au scroll, la salutation s'efface et les catégories se replient en
/// pastilles ; ce qui reste épinglé en haut (recherche + catégories
/// compactes) occupe alors la place de l'ancienne `HomeAppBar` — c'est
/// pourquoi `MainShell` ne fournit plus d'AppBar sur la branche Home.
///
/// Toutes les hauteurs sont déclarées ici et dans [CategoryIconsMetrics] :
/// ajouter un élément à l'en-tête se fait en touchant uniquement ces
/// constantes et [_buildContent], sans risque de désaccord entre la taille
/// réservée par le sliver et la taille réellement peinte.
/// Métriques de l'en-tête, publiques pour que l'écran puisse aimanter le
/// scroll sur l'un des deux états stables (voir [HomePageScreen]).
class HomeSliverHeaderMetrics {
  const HomeSliverHeaderMetrics._();

  /// Barre de recherche : la hauteur est exposée par le widget lui-même
  /// pour que l'extent réservé ne puisse pas diverger de ce qui est peint.
  static const double searchBarHeight = HomeSearchBar.height;

  static const double gap = AppDimens.small;
  static const double bottomGap = AppDimens.small;

  /// Largeur prise par la cloche de notifications et l'espace qui la sépare
  /// du texte : autant de moins pour la salutation.
  static const double _bellWidth = 56;

  /// Hauteur du bloc d'accueil, **mesurée** plutôt que posée.
  ///
  /// Elle valait 58 px en dur, et la question tenait donc sur une ligne
  /// unique — tronquée par une ellipse dès 375 px. Le produit s'engage sur
  /// trois langues : une traduction plus longue aurait coupé partout.
  /// On mesure le texte réel, à la largeur réelle et à l'échelle de police
  /// du système, et l'en-tête réserve ce qu'il faut.
  static double greetingHeight(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final available =
        media.size.width - AppDimens.appPaddingValue * 2 - _bellWidth;

    double lineHeight(String text, TextStyle? style, int maxLines) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: maxLines,
        textScaler: media.textScaler,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: available > 0 ? available : double.infinity);
      return painter.height;
    }

    return lineHeight(greeting, theme.textTheme.titleSmall, 1) +
        lineHeight(
          question,
          theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          2,
        );
  }

  /// Les deux lignes, exposées pour que la mesure porte sur le texte
  /// réellement peint et non sur une copie qui pourrait diverger.
  static const String greeting = 'Bonjour,';
  static const String question = "Qu'allons nous faire aujourd'hui ?";

  /// Distance de scroll sur laquelle se joue tout le repliement. La hauteur
  /// de barre de statut s'annule entre les deux extents, donc elle n'entre
  /// pas dans le calcul.
  static double collapseRange(BuildContext context) =>
      greetingHeight(context) +
      gap +
      (CategoryIconsMetrics.expandedHeight -
          CategoryIconsMetrics.collapsedHeight);
}

class HomeSliverHeader extends StatelessWidget {
  const HomeSliverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HomeSliverHeaderDelegate(
        topPadding: MediaQuery.of(context).padding.top,
        greetingHeight: HomeSliverHeaderMetrics.greetingHeight(context),
      ),
    );
  }
}

class _HomeSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// Hauteur de la barre de statut, à réserver nous-mêmes puisque l'écran
  /// n'a plus d'AppBar pour le faire.
  final double topPadding;

  /// Mesurée par [HomeSliverHeaderMetrics.greetingHeight] : elle dépend de
  /// la langue, de la largeur et de l'échelle de police.
  final double greetingHeight;

  const _HomeSliverHeaderDelegate({
    required this.topPadding,
    required this.greetingHeight,
  });

  static const double _searchBarHeight =
      HomeSliverHeaderMetrics.searchBarHeight;
  static const double _gap = HomeSliverHeaderMetrics.gap;
  static const double _bottomGap = HomeSliverHeaderMetrics.bottomGap;

  @override
  double get maxExtent =>
      topPadding +
      greetingHeight +
      _gap +
      _searchBarHeight +
      _gap +
      CategoryIconsMetrics.expandedHeight +
      _bottomGap;

  @override
  double get minExtent =>
      topPadding +
      _searchBarHeight +
      _gap +
      CategoryIconsMetrics.collapsedHeight +
      _bottomGap;

  /// Distance sur laquelle se joue tout le repliement.
  double get _collapseRange => maxExtent - minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = _collapseRange <= 0
        ? 0.0
        : (shrinkOffset / _collapseRange).clamp(0.0, 1.0);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      // L'ombre n'apparaît qu'une fois l'en-tête réellement épinglé, pour
      // détacher la barre du contenu qui défile dessous.
      elevation: lerpDouble(0, 3, t)!,
      shadowColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.15),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // La salutation garde sa place tant qu'on est en haut, puis
            // se comprime jusqu'à disparaître. `ClipRect` + hauteur
            // interpolée évitent tout débordement pendant la transition.
            ClipRect(
              child: Align(
                alignment: Alignment.topLeft,
                heightFactor: 1 - t,
                child: Opacity(
                  // On efface la salutation plus vite que la hauteur ne se
                  // réduit : elle a disparu avant d'être écrasée.
                  opacity: (1 - t * 1.6).clamp(0.0, 1.0),
                  child: SizedBox(
                    height: greetingHeight,
                    child: const _GreetingRow(),
                  ),
                ),
              ),
            ),
            SizedBox(height: lerpDouble(_gap, 0, t)),
            const HomeSearchBar(),
            const SizedBox(height: _gap),
            Expanded(child: CategoryIcons(collapseProgress: t)),
            const SizedBox(height: _bottomGap),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_HomeSliverHeaderDelegate oldDelegate) =>
      oldDelegate.topPadding != topPadding ||
      oldDelegate.greetingHeight != greetingHeight;
}

/// Ancien contenu de `HomeAppBar`, désormais rendu dans l'en-tête pour
/// pouvoir défiler et s'effacer avec lui.
class _GreetingRow extends StatelessWidget {
  const _GreetingRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.appPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Le bloc a une hauteur fixe : le texte doit tenir sur une
          // ligne, d'où la formulation courte et le garde-fou d'ellipse.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HomeSliverHeaderMetrics.greeting,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  HomeSliverHeaderMetrics.question,
                  // Deux lignes : l'en-tête réserve exactement ce que ce
                  // texte occupe, dans la langue et à l'échelle en cours.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.pushNamed('notifications'),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.small),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(AppDimens.radius10),
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              child: SvgPicture.asset(
                'assets/icons/notifications.svg',
                height: 26,
                width: 26,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
