part of 'business_card.dart';

/// « ★ 4,8 (32) », puis « Ouvert · jusqu'à 22:00 ».
///
/// Deux lignes, pas une : sur une tuile de grille de 183 px, les deux ne
/// tiennent pas côte à côte, et couper « jusqu'à 22:00 » par une ellipse
/// retirait précisément l'information qu'on cherche.
///
/// Sans avis : « Pas encore d'avis », jamais « 0,0 » — un commerce sans avis
/// n'est pas un commerce mal noté. Sans réponse du serveur sur l'ouverture,
/// on ne dit rien : mieux vaut un silence qu'un « Ouvert » inventé.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final other = OtherTheme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final open = business.isOpenNow;
    final String? opening = switch (open) {
      null => null,
      true =>
        business.closesAt == null
            ? 'Ouvert'
            : "Ouvert · jusqu'à ${business.closesAt}",
      false =>
        business.opensAt == null
            ? 'Fermé'
            : 'Fermé · ouvre à ${business.opensAt}',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (business.hasRating)
          Row(
            children: [
              Icon(Icons.star_rounded, size: 14, color: other.rating),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  '${business.rating.toStringAsFixed(1).replaceAll('.', ',')} '
                  '(${business.reviewCount})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            "Pas encore d'avis",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        if (opening != null) ...[
          const SizedBox(height: 2),
          Text(
            opening,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(
              color: open == true
                  ? other.onSuccessContainer
                  : scheme.onSurfaceVariant,
              fontWeight: open == true ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

/// Ce qu'on peut y faire. Seules les pastilles vraies s'affichent : une
/// pastille grisée pour dire « on ne peut pas » encombre sans informer.
class _Capabilities extends StatelessWidget {
  const _Capabilities({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final other = OtherTheme.of(context);

    return Wrap(
      spacing: AppDimens.tiny + 2,
      runSpacing: AppDimens.tiny,
      children: [
        if (business.canOrder)
          _Pill(
            label: 'Commander',
            icon: Icons.shopping_bag_outlined,
            color: scheme.onSecondaryContainer,
            surface: scheme.secondaryContainer,
          ),
        if (business.canBook)
          _Pill(
            label: 'Réserver',
            icon: Icons.event_available_outlined,
            color: scheme.onPrimaryContainer,
            surface: scheme.primaryContainer,
          ),
        if (business.hasInStore)
          _Pill(
            label: 'En boutique',
            icon: Icons.storefront_outlined,
            color: other.onWarningContainer,
            surface: other.warningContainer,
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.color,
    required this.surface,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.small,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      // Le libellé peut céder : à 160 % de police, « En boutique » ne tient
      // plus dans la moitié d'une tuile, et une pastille qui déborde de sa
      // carte est pire qu'une pastille coupée.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une étiquette posée sur la photo.
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.small,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
