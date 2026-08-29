import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final bool showReviewCount;
  final double iconSize;

  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.showReviewCount = true,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: OtherTheme.of(context).ratingContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: OtherTheme.of(context).onRatingContainer,
                size: iconSize,
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w900,
                  color: OtherTheme.of(context).onRatingContainer,
                ),
              ),
            ],
          ),
        ),
        if (showReviewCount) ...[
          const SizedBox(width: 8),
          Text(
            "$reviewCount avis",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
