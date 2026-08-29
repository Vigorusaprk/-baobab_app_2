import 'dart:ui';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class BusinessHeroSection extends StatelessWidget {
  final UIBusiness uiBusiness;
  final Business business;

  const BusinessHeroSection({
    super.key,
    required this.uiBusiness,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: ReviewApiService().getReviews(uiBusiness.business.id),
      builder: (context, snapshot) {
        double rating;
        int reviewCount;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final reviews = snapshot.data!;
          reviewCount = reviews.length;
          rating =
              reviews.map((r) => r.rating).reduce((a, b) => a + b) /
              reviewCount;
        } else {
          rating = uiBusiness.business.rating;
          reviewCount = uiBusiness.business.reviewCount;
        }

        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 130,
                left: 5,
                right: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 15.0,
                              sigmaY: 15.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLowest
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLowest
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    uiBusiness.business.name,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(
                                          letterSpacing: -0.5,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildBadge(
                                        context,
                                        icon: Icons.star_rounded,
                                        label: "${rating.toStringAsFixed(1)} ",
                                      ),
                                      const SizedBox(width: 1),
                                      _buildBadge(
                                        context,
                                        icon: Icons.comment,
                                        label: "$reviewCount avis",
                                        isStatus: true,
                                      ),
                                      const SizedBox(width: 12),
                                      _buildBadge(
                                        context,
                                        icon: Icons.circle,
                                        label: uiBusiness.isOpen
                                            ? 'OUVERT'
                                            : 'FERMÉ',
                                        isStatus: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 55,
                left: 50,
                right: 50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    border: Border.all(
                      color: uiBusiness
                          .categoryColor(context)
                          .withValues(alpha: 0.7),
                      width: 5.5,
                    ),
                  ),
                  child: Container(
                    child: business.profilImg.isNotEmpty
                        ? Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(business.profilImg),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Icon(
                            uiBusiness.categoryIcon,
                            size: 45,
                            color: uiBusiness.categoryColor(context),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isStatus = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isStatus ? 15 : 18,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
