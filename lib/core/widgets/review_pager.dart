import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// Des avis **par deux**, qui se feuillettent horizontalement.
///
/// Empilés verticalement, dix avis repoussent tout ce qui suit hors de
/// l'écran : sur une fiche de réservation, la barre de validation se
/// retrouvait à dix écrans du bas de page. Ici la section garde une hauteur
/// fixe, on feuillette pour lire la suite, et les points disent combien il en
/// reste.
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
  int _page = 0;

  /// La hauteur d'un avis : le nom, deux lignes de propos, et le bouton
  /// « Voir plus » quand il apparaît.
  static const double _itemHeight = 104;

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

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    if (pages.isEmpty) return const SizedBox.shrink();

    // La hauteur suit la taille de texte du système : figée en pixels, elle
    // coupait le propos de qui lit en grand.
    final height =
        MediaQuery.textScalerOf(context).scale(_itemHeight) * widget.perPage;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pages[index],
            ),
          ),
        ),
        if (pages.length > 1) ...[
          AppDimens.spacerSmall,
          _Dots(count: pages.length, current: _page),
        ],
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
              // Le point courant s'allonge au lieu de changer de taille :
              // une pastille qui grossit fait sauter la rangée entière.
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
