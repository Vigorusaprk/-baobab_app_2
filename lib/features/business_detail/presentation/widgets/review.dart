import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_detail_skeleton.dart';
import 'package:baobabe_0_2/core/widgets/custom_review_item.dart';
import 'package:baobabe_0_2/core/widgets/rating_stars.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/write_review_dialog.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';

class RestaurantReview extends StatefulWidget {
  final Business business;
  const RestaurantReview({super.key, required this.business});

  @override
  State<RestaurantReview> createState() => _RestaurantReviewState();
}

class _RestaurantReviewState extends State<RestaurantReview> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    _reviewsFuture = ReviewApiService().getReviews(widget.business.id);
  }

  void _refreshReviews() {
    setState(() {
      _loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Skeletonizer(
            enabled: true,
            child: ReviewSectionSkeleton(),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  // Une trace d'exception ne dit rien à qui lit un avis :
                  // on nomme ce qui a échoué et ce qu'on peut faire.
                  const Text(
                    "Les avis n'ont pas pu être chargés.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomActionButton(
                    label: 'Réessayer',
                    icon: Icons.refresh_rounded,
                    onPressed: _refreshReviews,
                  ),
                ],
              ),
            ),
          );
        }
        final reviews = snapshot.data ?? [];
        final totalReviews = reviews.length;
        final avgRating = totalReviews > 0
            ? reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                  totalReviews
            : 0.0;

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radius20),
                color: Theme.of(context).cardColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        ReadOnlyStars(rating: avgRating, size: 16),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          totalReviews.toString(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Avis',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    // Le libellé était peint avec `textTheme.bodySmall`,
                    // qui porte la couleur de texte de page : gris foncé sur
                    // le vert d'action, donc illisible. Le bouton partagé
                    // déduit sa couleur de texte de son fond.
                    CustomActionButton(
                      label: 'Écrire un avis',
                      assetPath: 'assets/icons/commen.svg',
                      onPressed: () => showWriteReviewDialog(
                        context,
                        widget.business,
                        onSubmitted: _refreshReviews,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return CustomReviewItem(
                  author: review.userName,
                  rating: review.rating.toDouble(),
                  createdAt: review.createdAt,
                  comment: review.comment,
                  accent: index == 0,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
