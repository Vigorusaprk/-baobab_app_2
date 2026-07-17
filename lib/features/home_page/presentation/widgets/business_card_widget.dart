import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_card_background.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_card_category_badge.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_card_info_overlay.dart';
import 'package:flutter/material.dart';

class BusinessCardWidget extends StatelessWidget {
  final UIBusiness uiBusiness;

  const BusinessCardWidget({super.key, required this.uiBusiness});

  @override
  Widget build(BuildContext context) {
    final reviewService = ReviewApiService();
    return FutureBuilder<List<Review>>(
      future: reviewService.getReviews(uiBusiness.business.id),
      builder: (context, snapshot) {
        // Calcul de la note moyenne réelle
        double rating;
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final reviews = snapshot.data!;
          rating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
        } else {
          rating = uiBusiness.business.rating; // fallback
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: uiBusiness.categoryColor, width: 2.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned.fill(child: BusinessCardBackground(uiBusiness: uiBusiness)),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: BusinessCardCategoryBadge(uiBusiness: uiBusiness),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: BusinessCardInfoOverlay(uiBusiness: uiBusiness, rating: rating),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
