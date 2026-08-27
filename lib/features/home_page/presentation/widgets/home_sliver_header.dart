import 'dart:ui' show lerpDouble;

import 'package:baobabe_0_2/core/themes/app_colors.dart';
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

  /// Bloc « Bonjours, / Où allons-nous ? » + cloche : c'est lui qui
  /// disparaît pour laisser la place à la barre épinglée.
  static const double greetingHeight = 58;

  /// Barre de recherche : la hauteur est exposée par le widget lui-même
  /// pour que l'extent réservé ne puisse pas diverger de ce qui est peint.
  static const double searchBarHeight = HomeSearchBar.height;

  static const double gap = AppDimens.small;
  static const double bottomGap = AppDimens.small;

  /// Distance de scroll sur laquelle se joue tout le repliement. La hauteur
  /// de barre de statut s'annule entre les deux extents, donc cette valeur
  /// ne dépend pas de l'appareil.
  static const double collapseRange =
      greetingHeight +
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
      ),
    );
  }
}

class _HomeSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// Hauteur de la barre de statut, à réserver nous-mêmes puisque l'écran
  /// n'a plus d'AppBar pour le faire.
  final double topPadding;

  const _HomeSliverHeaderDelegate({required this.topPadding});

  static const double _greetingHeight = HomeSliverHeaderMetrics.greetingHeight;
  static const double _searchBarHeight =
      HomeSliverHeaderMetrics.searchBarHeight;
  static const double _gap = HomeSliverHeaderMetrics.gap;
  static const double _bottomGap = HomeSliverHeaderMetrics.bottomGap;

  @override
  double get maxExtent =>
      topPadding +
      _greetingHeight +
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
      color: AppColors.background,
      // L'ombre n'apparaît qu'une fois l'en-tête réellement épinglé, pour
      // détacher la barre du contenu qui défile dessous.
      elevation: lerpDouble(0, 3, t)!,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.15),
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
                  child: const SizedBox(
                    height: _greetingHeight,
                    child: _GreetingRow(),
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
      oldDelegate.topPadding != topPadding;
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Bonjours,",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
              Text(
                "Ou alons nous?",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.pushNamed('notifications'),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.small),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(AppDimens.radius10),
                color: AppColors.surface,
              ),
              child: SvgPicture.asset(
                'assets/icons/notifications.svg',
                height: 26,
                width: 26,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
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
