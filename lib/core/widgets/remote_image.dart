import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Une image venue du réseau, mise en cache sur l'appareil.
///
/// Toutes les images distantes de l'application passent par ici. Trois
/// raisons, dans l'ordre d'importance pour le contexte du produit :
///
/// 1. **Le cache.** `Image.network` ne garde rien sur le disque : chaque
///    retour sur l'accueil relançait les téléchargements. Sur un réseau
///    intermittent, c'est la dépense la plus visible de l'application.
/// 2. **L'attente est montrée**, avec la même forme que le reste : un
///    rectangle qui scintille, pas un trou blanc puis un saut.
/// 3. **L'échec est prévu.** Beaucoup d'URL en base sont des liens de page
///    plutôt que des fichiers image ; le repli doit être une forme propre,
///    jamais l'icône de rupture du navigateur.
class RemoteImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;

  /// Ce qu'on affiche quand il n'y a pas d'image, ou qu'elle ne charge pas.
  final Widget? fallback;

  const RemoteImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final source = url;
    if (source == null || source.isEmpty) {
      return fallback ?? const RemoteImageFallback();
    }

    return CachedNetworkImage(
      imageUrl: source,
      fit: fit,
      // Une image déjà téléchargée ne repasse pas par le réseau, même après
      // un redémarrage.
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, _) => const Skeletonizer(
        enabled: true,
        child: Bone(width: double.infinity, height: double.infinity),
      ),
      errorWidget: (_, _, _) => fallback ?? const RemoteImageFallback(),
    );
  }
}

/// La forme neutre affichée à la place d'une image absente ou illisible.
class RemoteImageFallback extends StatelessWidget {
  final double iconSize;

  const RemoteImageFallback({super.key, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: iconSize,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Variante ronde ou arrondie, pour une vignette.
class RemoteThumbnail extends StatelessWidget {
  final String? url;
  final double size;
  final double radius;

  const RemoteThumbnail({
    super.key,
    required this.url,
    this.size = 48,
    this.radius = AppDimens.radius12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: RemoteImage(url: url),
      ),
    );
  }
}
