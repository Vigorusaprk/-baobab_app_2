import 'package:baobabe_0_2/core/services/metrics_service.dart';
import 'package:baobabe_0_2/core/widgets/baobab_hero_banner.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Construit les éléments HeroBannerItem UNIQUEMENT à partir des vraies
/// données renvoyées par le backend Supabase (featuredBusinesses).
///
/// Si aucune campagne n'est active en base, renvoie une liste vide [].
class DynamicHeroBannerMapper {
  static List<HeroBannerItem> fromFeatured({
    required BuildContext context,
    required List<FeaturedBusiness> featured,
  }) {
    // Si aucune campagne active sur Supabase, on ne renvoie rien (la section reste masquée)
    if (featured.isEmpty) {
      return const [];
    }

    return featured.map((item) {
      final business = item.business;
      final offer = item.offer;

      // Détermine la variante visuelle selon la catégorie du commerce
      final variant = _detectVariant(business.categorySlug);

      // Badge selon la présence d'une offre ciblée
      final badgeText = offer != null ? 'Offre spéciale' : 'À découvrir';

      // Titre : soit l'offre ciblée, soit la description/slogan du commerce
      final title = offer != null
          ? offer.name
          : (business.description.isNotEmpty
              ? business.description
              : business.name);

      // Description
      final description = offer != null
          ? 'Profitez de cette offre exclusive chez ${business.name}.'
          : (business.address.isNotEmpty
              ? business.address
              : 'Découvrez notre établissement et nos services.');

      // Image réelle de fond venant de Supabase
      final imageUrl = business.bgImg.isNotEmpty
          ? business.bgImg
          : (business.images.isNotEmpty
              ? business.images.first
              : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800');

      // Détection de l'icône de catégorie
      final icon = _detectIcon(business.categorySlug);

      return HeroBannerItem(
        badgeText: badgeText,
        businessName: business.name,
        businessIcon: icon,
        title: title,
        description: description,
        buttonText: offer != null ? 'Voir l\'offre' : 'Découvrir',
        imageUrl: imageUrl,
        variant: variant,
        discountBadge: offer != null ? 'Spécial' : null,
        onTap: () {
          // 1. Enregistre la métrique (clic réel mesuré pour le commerçant)
          MetricsService.instance.click(
            businessId: business.id,
            offerId: offer?.id,
          );

          // 2. Redirige vers la bonne fiche
          if (offer != null) {
            context.pushNamed('offerDetail', pathParameters: {'id': offer.id});
          } else {
            context.pushNamed('businessDetail', pathParameters: {'id': business.id});
          }
        },
      );
    }).toList();
  }

  /// Détermine la couleur de fond de la bannière selon la catégorie
  static BannerVariant _detectVariant(String slug) {
    switch (slug.toLowerCase()) {
      case 'restaurant':
      case 'cafe':
      case 'bar':
      case 'fastfood':
        return BannerVariant.editorial; // Vert forêt
      case 'spa':
      case 'beauty':
      case 'cosmetics':
      case 'wellness':
        return BannerVariant.promotional; // Beige rosé chaud
      default:
        return BannerVariant.highlight; // Vert sombre nuit
    }
  }

  /// Détermine la petite icône
  static IconData _detectIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'restaurant':
      case 'cafe':
        return Icons.restaurant;
      case 'spa':
      case 'beauty':
        return Icons.spa;
      case 'hotel':
        return Icons.hotel;
      case 'shopping':
      case 'boutique':
        return Icons.shopping_bag;
      default:
        return Icons.storefront;
    }
  }
}
