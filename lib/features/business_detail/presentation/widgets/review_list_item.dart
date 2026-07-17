import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review_stars.dart';
import 'package:flutter/material.dart';

/// Carte affichant un avis individuel dans la liste des avis d'un business.
/// Extrait de review.dart pour garder ce fichier concis ; comportement
/// identique.
class ReviewListItem extends StatelessWidget {
  final Review review;

  const ReviewListItem({super.key, required this.review});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return "Aujourd'hui";
    if (difference.inDays == 1) return "Hier";
    if (difference.inDays < 7) return "Il y a ${difference.inDays} jours";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review.userAvatar != null && review.userAvatar!.isNotEmpty
                      ? NetworkImage(review.userAvatar!)
                      : null,
                  child: review.userAvatar == null || review.userAvatar!.isEmpty ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName ?? 'Anonyme', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          ...buildReviewStars(review.rating.toDouble(), 12),
                          const SizedBox(width: 8),
                          Text(
                            ' • ${_formatDate(review.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment ?? ''),
          ],
        ),
      ),
    );
  }
}
