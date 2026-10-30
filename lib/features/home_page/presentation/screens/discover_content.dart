import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/discover_state.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_message.dart';
import 'package:flutter/material.dart';
import 'discover_carousel.dart';

/// Choisit le contenu de Découvrir selon l'état du flux.
class DiscoverContent extends StatelessWidget {
  const DiscoverContent({super.key, required this.state, required this.sponsoredBusinessIds, required this.onRetry, required this.onClearCategory, required this.onLoadMore, required this.onSave, required this.onSkip, required this.onOpenOffer});

  final DiscoverState state;
  final Set<String> sponsoredBusinessIds;
  final VoidCallback onRetry;
  final VoidCallback onClearCategory;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverOffer) onOpenOffer;

  @override
  Widget build(BuildContext context) {
    if (state.status == DiscoverStatus.failure) {
      return SearchMessage(title: 'Découvrir est indisponible', body: state.message ?? 'Réessayez dans un instant.', actionLabel: 'Réessayer', onAction: onRetry);
    }
    if (state.status == DiscoverStatus.initial || (state.status == DiscoverStatus.loading && state.items.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.visibleItems.isEmpty) {
      return SearchMessage(title: 'Aucune offre à découvrir', body: state.categorySlug == null ? 'De nouvelles offres apparaîtront ici.' : 'Essayez une autre catégorie.', actionLabel: state.categorySlug == null ? null : 'Tout découvrir', onAction: state.categorySlug == null ? null : onClearCategory);
    }
    return DiscoverCarousel(key: ValueKey(state.categorySlug), offers: state.visibleItems, savedIds: state.savedIds, sponsoredBusinessIds: sponsoredBusinessIds, onLoadMore: onLoadMore, onSave: onSave, onSkip: onSkip, onOpenOffer: onOpenOffer);
  }
}
