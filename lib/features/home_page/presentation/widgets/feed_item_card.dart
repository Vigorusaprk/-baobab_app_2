import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../domain/entities/feed_item.dart';

/// Carte d'un élément du feed. Même structure pour notif et promo,
/// seule la couleur d'accent et la présence d'un bouton d'action changent.
class FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;

  const FeedItemCard({Key? key, required this.item, required this.onTap})
    : super(key: key);

  bool get _isPromo => item.type == FeedItemType.promotion;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPromo
                ? OtherTheme.of(context).rating
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              _isPromo
                  ? 'assets/icons/offer.svg'
                  : 'assets/icons/notifications.svg',
              height: 30,
              width: 30,
              colorFilter: ColorFilter.mode(
                _isPromo
                    ? OtherTheme.of(context).onRatingContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: Theme.of(context).textTheme.labelSmall!,
                  ),
                  if (item.actionLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.actionLabel!,
                      style: TextStyle(
                        color: OtherTheme.of(context).onRatingContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
