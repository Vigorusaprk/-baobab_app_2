import 'package:baobabe_0_2/core/services/metrics_service.dart';
import 'package:baobabe_0_2/core/widgets/baobab_hero_banner.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'hero_banner_category_style.dart';

/// Convertit les campagnes réelles en bannières et fournit un aperçu en debug.
class DynamicHeroBannerMapper {
  static List<HeroBannerItem> fromFeatured({
    required BuildContext context,
    required List<FeaturedBusiness> featured,
  }) {
    if (featured.isEmpty) {
      return kDebugMode ? [_preview()] : const [];
    }

    return featured.map((item) {
      final business = item.business;
      final offer = item.offer;

      // Détermine la variante visuelle selon la catégorie du commerce
      final variant = HeroBannerCategoryStyle.variant(business.categorySlug);

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
              : 'Découvrez ce commerce et ses services.');

      // Image réelle de fond venant de Supabase
      final imageUrl = business.bgImg.isNotEmpty
          ? business.bgImg
          : (business.images.isNotEmpty
                ? business.images.first
                : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800');

      // Détection de l'icône de catégorie
      final icon = HeroBannerCategoryStyle.icon(business.categorySlug);

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
            context.pushNamed(
              'businessDetail',
              pathParameters: {'id': business.id},
            );
          }
        },
      );
    }).toList();
  }

  /// Le contenu fictif ne navigue pas et n'envoie aucune métrique.
  static HeroBannerItem _preview() => const HeroBannerItem(
    badgeText: 'APERÇU FICTIF',
    businessName: 'Commerce de démonstration',
    businessIcon: Icons.storefront,
    title: 'Votre commerce à la une',
    description: 'Exemple fictif pour visualiser la bannière publicitaire.',
    buttonText: 'Aperçu seulement',
    imageUrl:
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
    variant: BannerVariant.editorial,
    onTap: _ignorePreviewTap,
  );

  static void _ignorePreviewTap() {}
}
