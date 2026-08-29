import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

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
            color: AppColors.ratingSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.ratingContent,
                size: iconSize,
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.ratingContent,
                  fontSize: iconSize - 2,
                ),
              ),
            ],
          ),
        ),
        if (showReviewCount) ...[
          const SizedBox(width: 8),
          Text(
            "$reviewCount avis",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
