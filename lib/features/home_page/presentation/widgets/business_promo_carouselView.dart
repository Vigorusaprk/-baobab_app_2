import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/see_all.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './business_promo_card.dart';

/// Partie "vue" pure du carrousel promo : reçoit une liste déjà prête
/// de [UIBusiness] et affiche le `PageView` + les indicateurs de page.
///
/// Ne dépend d'aucun Bloc — réutilisable tel quel ailleurs dans l'app
/// (ex: écran de recherche, favoris...) si besoin d'afficher une liste
/// de cartes promo sans passer par `BusinessBloc`.
class BusinessPromoCarouselView extends StatefulWidget {
  final List<UIBusiness> uiBusinesses;
  final String Function(UIBusiness uiBusiness)? badgeLabelBuilder;
  final String? Function(UIBusiness uiBusiness)? subtitleBuilder;
  final void Function(UIBusiness uiBusiness)? onCardTap;

  /// Card height. Leave null to size responsively (a fraction of the
  /// screen height) instead of forcing one fixed pixel value on every
  /// device — pass an explicit value only when a specific height is
  /// genuinely required by the caller.
  final double? cardHeight;
  final double viewportFraction;

  /// Titre de la section affiché au-dessus du carrousel (ex: "Sponsorisé").
  /// Si null, aucun en-tête n'est affiché.
  final String? title;

  /// Callback optionnel pour un lien "Voir tout" à droite du titre.
  /// Si null et `title` est fourni, l'en-tête n'affiche que le titre seul.
  final VoidCallback? onSeeAllTap;

  const BusinessPromoCarouselView({
    super.key,
    required this.uiBusinesses,
    this.badgeLabelBuilder,
    this.subtitleBuilder,
    this.onCardTap,
    this.cardHeight,
    this.viewportFraction = 0.86,
    this.title,
    this.onSeeAllTap,
  });

  @override
  State<BusinessPromoCarouselView> createState() =>
      _BusinessPromoCarouselViewState();
}

class _BusinessPromoCarouselViewState extends State<BusinessPromoCarouselView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleTap(UIBusiness uiBusiness) {
    if (widget.onCardTap != null) {
      widget.onCardTap!(uiBusiness);
      return;
    }
    context.pushNamed(
      'businessDetail',
      pathParameters: {'id': uiBusiness.business.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.uiBusinesses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Padding(
            padding: AppDimens.appPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (widget.onSeeAllTap != null) SeeAll(onTap: widget.onSeeAllTap),
              ],
            ),
          ),
        ],
        SizedBox(
          height: AppDimens.horizontalScrollHeight(
            context,
            0.35,
            min: 220,
            max: 220,
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.uiBusinesses.length,
            padEnds: false,
            itemBuilder: (context, index) {
              final uiBusiness = widget.uiBusinesses[index];
              return Padding(
                padding: AppDimens.carouselPadding(
                  index,
                  widget.uiBusinesses.length,
                ),
                child: BusinessPromoCard(
                  uiBusiness: uiBusiness,
                  isNew: uiBusiness.isNew,
                  badgeLabel:
                      widget.badgeLabelBuilder?.call(uiBusiness) ?? 'Nouveau',
                  subtitle: widget.subtitleBuilder?.call(uiBusiness),
                  onTap: () => _handleTap(uiBusiness),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
