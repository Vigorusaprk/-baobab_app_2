import 'package:baobabe_0_2/features/home_page/domain/entities/discover_entry.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/discover_state.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'discover_carousel.dart';

/// Choisit le contenu de Découvrir selon l'état du flux.
class DiscoverContent extends StatelessWidget {
  const DiscoverContent({
    super.key,
    required this.state,
    required this.campaigns,
    required this.onRetry,
    required this.onClearCategory,
    required this.onLoadMore,
    required this.onSave,
    required this.onSkip,
    required this.onOpenOffer,
  });

  final DiscoverState state;
  final List<FeaturedBusiness> campaigns;
  final VoidCallback onRetry;
  final VoidCallback onClearCategory;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverEntry) onOpenOffer;

  @override
  Widget build(BuildContext context) {
    if (state.status == DiscoverStatus.failure) {
      return SearchMessage(
        title: 'Découvrir est indisponible',
        body: state.message ?? 'Réessayez dans un instant.',
        actionLabel: 'Réessayer',
        onAction: onRetry,
      );
    }
    if (state.status == DiscoverStatus.initial ||
        (state.status == DiscoverStatus.loading && state.items.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.visibleItems.isEmpty) {
      final canReset =
          state.categorySlug != null || state.filters.facetCount > 0;
      return SearchMessage(
        title: 'Rien à découvrir pour ces critères',
        body: 'Essayez d’autres filtres ou catégories.',
        actionLabel: canReset ? 'Tout réinitialiser' : null,
        onAction: canReset ? onClearCategory : null,
      );
    }
    final campaigns = this.campaigns.where(_campaignMatchesFilters).toList();
    return DiscoverCarousel(
      key: ValueKey(state.categorySlug),
      items: state.visibleItems,
      savedIds: state.savedIds,
      skippedIds: state.skippedIds,
      campaigns: campaigns,
      showPreviewAd: kDebugMode && campaigns.isEmpty,
      onLoadMore: onLoadMore,
      onSave: onSave,
      onSkip: onSkip,
      onOpenEntry: onOpenOffer,
    );
  }

  bool _campaignMatchesFilters(FeaturedBusiness campaign) {
    final business = campaign.business;
    if (state.categorySlug != null &&
        business.categorySlug != state.categorySlug) {
      return false;
    }
    if (state.filters.openNow && business.isOpenNow != true) return false;
    final rating = state.filters.minRating;
    if (rating != null && (!business.hasRating || business.rating < rating)) {
      return false;
    }
    return switch (state.filters.fulfilment) {
      Fulfilment.order => business.canOrder,
      Fulfilment.booking => business.canBook,
      Fulfilment.inStore => business.hasInStore,
      null => true,
    };
  }
}
