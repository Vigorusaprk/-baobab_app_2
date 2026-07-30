import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class BusinessCommentsSection extends StatelessWidget {
  final Business business;
  const BusinessCommentsSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: ReviewApiService().getReviews(business.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun avis pour le moment.'));
        }
        final reviews = snapshot.data!;
        return Column(
          children: reviews
              .map(
                (review) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        review.userAvatar != null &&
                            review.userAvatar!.isNotEmpty
                        ? NetworkImage(review.userAvatar!)
                        : null,
                    child:
                        review.userAvatar == null || review.userAvatar!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(review.userName ?? 'Anonyme'),
                  subtitle: Text(review.comment ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
