import 'dart:async';
import 'package:flutter/material.dart';

/// Les types de bannières visibles sur la maquette
enum BannerVariant {
  editorial,   // Fond vert forêt - Découverte établissement (ex: Le Jardin Kinshasa)
  promotional, // Fond beige rosé chaud - Offre spéciale (ex: Salon Beauté)
  highlight,   // Fond vert sombre nuit - Entreprise & Produits locaux
}

/// Modèle simple pour décrire une bannière publicitaire
class HeroBannerItem {
  final String badgeText;
  final String businessName;
  final IconData? businessIcon;
  final String title;
  final String description;
  final String buttonText;
  final String imageUrl;
  final BannerVariant variant;
  final String? discountBadge;
  final VoidCallback onTap;

  const HeroBannerItem({
    required this.badgeText,
    required this.businessName,
    this.businessIcon = Icons.eco,
    required this.title,
    required this.description,
    this.buttonText = 'Découvrir',
    required this.imageUrl,
    this.variant = BannerVariant.editorial,
    this.discountBadge,
    required this.onTap,
  });
}

/// Carrousel avec défilement automatique et indicateurs de points (Dots)
class BaobabHeroBannerCarousel extends StatefulWidget {
  final List<HeroBannerItem> banners;

  const BaobabHeroBannerCarousel({super.key, required this.banners});

  @override
  State<BaobabHeroBannerCarousel> createState() => _BaobabHeroBannerCarouselState();
}

class _BaobabHeroBannerCarouselState extends State<BaobabHeroBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    // Défilement automatique toutes les 4 secondes
    if (widget.banners.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!_pageController.hasClients) return;
        final next = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 205,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final item = widget.banners[index];
              return BaobabHeroBannerCard(item: item);
            },
          ),
        ),
        // Petits points indicateurs (Dots)
        if (widget.banners.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == i
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Carte unitaire fidèle à la maquette
class BaobabHeroBannerCard extends StatelessWidget {
  final HeroBannerItem item;

  const BaobabHeroBannerCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isPromo = item.variant == BannerVariant.promotional;

    final Color bgColor = switch (item.variant) {
      BannerVariant.editorial => const Color(0xFF132A1C),
      BannerVariant.promotional => const Color(0xFFF3DFD1),
      BannerVariant.highlight => const Color(0xFF0F1F17),
    };

    final Color textColor = isPromo ? const Color(0xFF1C1C1C) : Colors.white;
    final Color subtextColor = isPromo ? const Color(0xFF555555) : Colors.white.withValues(alpha: 0.8);

    final Color badgeBg = switch (item.variant) {
      BannerVariant.editorial => const Color(0xFFD6E8B5),
      BannerVariant.promotional => const Color(0xFFE26D5C),
      BannerVariant.highlight => Colors.transparent,
    };
    final Color badgeTextCol = switch (item.variant) {
      BannerVariant.editorial => const Color(0xFF23441E),
      BannerVariant.promotional => Colors.white,
      BannerVariant.highlight => const Color(0xFF8FD19E),
    };

    final Color buttonBg = isPromo ? const Color(0xFF8D4925) : const Color(0xFFE6F3CC);
    final Color buttonTextCol = isPromo ? Colors.white : const Color(0xFF183321);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // 1. Photo à droite
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: MediaQuery.of(context).size.width * 0.55,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade400),
              ),
            ),

            // 2. Dégradé doux de transition
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: MediaQuery.of(context).size.width * 0.55,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Contenu à gauche
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                        border: item.variant == BannerVariant.highlight
                            ? Border.all(color: const Color(0xFF8FD19E), width: 1.2)
                            : null,
                      ),
                      child: Text(
                        item.badgeText.toUpperCase(),
                        style: TextStyle(
                          color: badgeTextCol,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Nom du commerce + icône
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.businessIcon != null) ...[
                          Icon(item.businessIcon, size: 14, color: isPromo ? buttonBg : const Color(0xFF8FD19E)),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            item.businessName,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Titre
                    Text(
                      item.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    Text(
                      item.description,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Bouton
                    InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: buttonBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.buttonText,
                              style: TextStyle(
                                color: buttonTextCol,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 12, color: buttonTextCol),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Macaron de réduction optionnel
            if (item.discountBadge != null)
              Positioned(
                bottom: 24,
                right: 20,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE89873).withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Jusqu\'à',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        item.discountBadge!,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
