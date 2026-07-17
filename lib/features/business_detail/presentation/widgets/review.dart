import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review_list_item.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review_stars.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/write_review_dialog.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshReviews,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }
        final reviews = snapshot.data ?? [];
        final totalReviews = reviews.length;
        final avgRating = totalReviews > 0
            ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews
            : 0.0;

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: AppColors.primary50),
                  borderRadius: BorderRadius.circular(100)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Row(
                          children: buildReviewStars(avgRating, 16),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          totalReviews.toString(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('Avis', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary50),
                      onPressed: () => showWriteReviewDialog(
                        context,
                        widget.business,
                        onSubmitted: _refreshReviews,
                      ),
                      icon: Container(
                        child: SvgPicture.asset(
                          "assets/icons/commen.svg",
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      label: const Text('Écrire un avis'),
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ReviewListItem(review: reviews[index]);
              },
            ),
          ],
        );
      },
    );
  }
}
