import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// Des avis **par deux**, qui se feuillettent horizontalement.
///
/// Empilés verticalement, dix avis repoussent tout ce qui suit hors de
/// l'écran : sur une fiche de réservation, la barre de validation se
/// retrouvait à plusieurs écrans du bas de page. Ici la section garde une
/// hauteur stable, on feuillette pour lire la suite, et les points disent
/// combien il en reste.
///
/// La hauteur est **mesurée**, pas décidée. Une valeur fixe laissait un grand
/// blanc entre le dernier avis et les points quand les propos tenaient sur
/// une ligne, et coupait ceux qui débordaient. Elle prend la hauteur de la
/// page la plus haute, de façon que feuilleter ne déplace pas ce qui suit.
///
/// Les avis lui sont **donnés déjà construits** : ce composant ne connaît ni
/// entité ni mise en forme d'un avis, seulement la pagination.
class ReviewPager extends StatefulWidget {
  const ReviewPager({super.key, required this.reviews, this.perPage = 2});

  final List<Widget> reviews;

  /// Deux par page : au-delà, la page devient assez haute pour qu'on la
  /// prenne pour la page entière et qu'on ne pense plus à feuilleter.
  final int perPage;

  @override
  State<ReviewPager> createState() => _ReviewPagerState();
}

class _ReviewPagerState extends State<ReviewPager> {
  final _controller = PageController();
  final _keys = <int, GlobalKey>{};
  final _heights = <int, double>{};
  int _page = 0;

  /// La hauteur du premier rendu, le temps que la mesure arrive : un avis
  /// d'une ligne, fois le nombre par page.
  static const double _estimate = 76;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<List<Widget>> get _pages {
    final pages = <List<Widget>>[];
    for (var i = 0; i < widget.reviews.length; i += widget.perPage) {
      pages.add(
        widget.reviews.sublist(
          i,
          (i + widget.perPage).clamp(0, widget.reviews.length),
        ),
      );
    }
    return pages;
  }

  /// Relève la hauteur réelle d'une page après son rendu.
  void _measure(int index) {
    final box = _keys[index]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final height = box.size.height;
    if ((_heights[index] ?? 0) == height) return;
    if (!mounted) return;
    setState(() => _heights[index] = height);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    if (pages.isEmpty) return const SizedBox.shrink();

    final measured = _heights.values.isEmpty
        ? null
        : _heights.values.reduce((a, b) => a > b ? a : b);
    // La mesure sert de plancher, jamais de plafond : la taille de texte du
    // système peut grandir entre deux rendus.
    final height =
        measured ??
        MediaQuery.textScalerOf(context).scale(_estimate) * widget.perPage;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: SizedBox(
            height: height,
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) => setState(() => _page = index),
              itemBuilder: (context, index) {
                final key = _keys.putIfAbsent(index, GlobalKey.new);
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _measure(index),
                );
                // `Align` donne au contenu des contraintes lâches : sans lui,
                // la page l'étire à la hauteur du cadre et la mesure rend
                // toujours cette même hauteur.
                return Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    key: key,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pages[index],
                  ),
                );
              },
            ),
          ),
        ),
        if (pages.length > 1) _Dots(count: pages.length, current: _page),
      ],
    );
  }
}

/// Les points : où l'on en est, et combien il en reste.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              // Le point courant s'allonge au lieu de grossir : une pastille
              // qui change de taille fait sauter la rangée entière.
              width: i == current ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == current ? scheme.primary : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
      ],
    );
  }
}
