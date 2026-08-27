import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/core/widgets/see_all.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import './business_card_widget.dart';

class BusinessCardsWidget extends StatefulWidget {
  /// Titre de la section affiché au-dessus du carrousel.
  final String title;

  /// Callback optionnel pour un lien "Voir tout" à droite du titre.
  final VoidCallback? onSeeAllTap;

  const BusinessCardsWidget({
    super.key,
    this.title = 'Découvrir',
    this.onSeeAllTap,
  });

  @override
  State<BusinessCardsWidget> createState() => _BusinessCardsWidgetState();
}

class _BusinessCardsWidgetState extends State<BusinessCardsWidget> {
  late PageController _pageController;
  double _pageOffset = 0;

  static const double _viewportFraction = 0.82;

  /// Sized as a fraction of the screen height instead of a fixed pixel
  /// value, so the card scales with the device instead of looking
  /// cramped on small phones or oversized on tablets.
  double get _cardHeight =>
      AppDimens.horizontalScrollHeight(context, 0.58, min: 420, max: 560);
  static const double _cardVerticalPadding = 20;
  static const double _cardHorizontalPadding = 10;
  static const double _baseScale = 0.9;
  static const double _scaleFactor = 0.1;
  static const double _baseOpacity = 0.5;
  static const double _opacityFactor = 0.5;
  static const double _verticalOffsetFactor = 20;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction)
      ..addListener(_onPageChanged);
  }

  void _onPageChanged() {
    setState(() {
      _pageOffset = _pageController.page!;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimens.appPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SeeAll(onTap: widget.onSeeAllTap),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    // On écoute le CategoryBloc sans condition de rebuild (peu coûteux)
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        return BlocBuilder<BusinessBloc, BusinessState>(
          // Optimisation : on ne rebuild que si l'état du business change
          // vraiment. `isLoadingMore` en fait partie — c'est lui qui fait
          // apparaître la carte skeleton en fin de liste pendant qu'une
          // page suivante se charge.
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) return true;
            if (current is BusinessLoaded && previous is BusinessLoaded) {
              return previous.businesses != current.businesses ||
                  previous.isLoadingMore != current.isLoadingMore;
            }
            return false;
          },
          builder: (context, state) {
            if (state is BusinessLoading) {
              return SizedBox(
                height: _cardHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _cardHorizontalPadding,
                    vertical: _cardVerticalPadding,
                  ),
                  child: const Skeletonizer(
                    enabled: true,
                    child: _BusinessCardSkeleton(),
                  ),
                ),
              );
            } else if (state is BusinessLoaded) {
              final uiBusinesses = state.businesses
                  .map((business) => UIBusiness(business))
                  .toList();
              return _buildStylizedScroll(uiBusinesses, state.isLoadingMore);
            } else if (state is BusinessError) {
              return SizedBox(
                height: _cardHeight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur : ${state.message}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<BusinessBloc>().add(LoadBusinesses()),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildStylizedScroll(
    List<UIBusiness> uiBusinesses,
    bool isLoadingMore,
  ) {
    if (uiBusinesses.isEmpty) {
      return SizedBox(
        height: _cardHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 60,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun établissement disponible',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final itemCount = uiBusinesses.length + (isLoadingMore ? 1 : 0);

    return SizedBox(
      height: _cardHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: itemCount,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          // La carte skeleton ajoutée en fin de liste pendant le chargement
          // de la page suivante — elle ne correspond à aucun business réel.
          final isTrailingSkeleton = index >= uiBusinesses.length;

          // Scroll infini : on prévient juste le bloc qu'on approche de la
          // fin de la liste chargée. Toute la logique (page suivante,
          // hasMore, anti-doublon) vit dans BusinessBloc — cette vue ne
          // fait que remonter l'information, elle ne sait rien de la
          // pagination elle-même.
          if (!isTrailingSkeleton && index == uiBusinesses.length - 2) {
            context.read<BusinessBloc>().add(const LoadMoreBusinesses());
          }

          final distance = (index - _pageOffset).abs().clamp(0.0, 1.0);
          final focus = Curves.easeInOutCubic.transform(1 - distance);

          final verticalOffset = _verticalOffsetFactor * (1 - focus);
          final scale = _baseScale + (focus * _scaleFactor);
          final opacity = _baseOpacity + (focus * _opacityFactor);

          return Transform.translate(
            key: isTrailingSkeleton
                ? const ValueKey('business-card-loading-more')
                : ValueKey(uiBusinesses[index].business.id),
            offset: Offset(0, verticalOffset),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: _cardVerticalPadding),
                  child: isTrailingSkeleton
                      ? const Skeletonizer(
                          enabled: true,
                          child: _BusinessCardSkeleton(),
                        )
                      : _buildPerspectiveCard(uiBusinesses[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerspectiveCard(UIBusiness uiBusiness) {
    // Style flat : pas de glow coloré, pas d'ombre supplémentaire ici —
    // BusinessCardWidget porte déjà sa propre ombre discrète (0.06
    // d'opacité). On garde juste le tap + le ripple.
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _navigateToBusinessDetail(context, uiBusiness.business.id),
        child: BusinessCardWidget(uiBusiness: uiBusiness),
      ),
    );
  }

  void _navigateToBusinessDetail(BuildContext context, String businessId) {
    context.pushNamed('businessDetail', pathParameters: {'id': businessId});
  }
}

/// Skeleton placeholder shaped like [BusinessCardWidget] (photo up top,
/// rating pill, name, description). Built entirely from [Bone] widgets
/// rather than plain Containers/Text — each part of the real card gets
/// its own explicit bone shape instead of relying on Skeletonizer to
/// guess one from arbitrary widgets, which is what made the previous
/// version look off.
class _BusinessCardSkeleton extends StatelessWidget {
  const _BusinessCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.cardBorderRadiusAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimens.cardBorderRadius),
                topRight: Radius.circular(AppDimens.cardBorderRadius),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned.fill(child: Bone()),
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: Bone(width: 44, height: 24, uniRadius: 8),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(words: 2, style: AppFonts.titleMedium),
                const SizedBox(height: 8),
                Bone.multiText(lines: 2, style: AppFonts.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
