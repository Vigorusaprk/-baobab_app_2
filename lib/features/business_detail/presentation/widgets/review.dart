import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart' show AuthBloc, AuthAuthenticated;

class CommentsSection extends StatelessWidget {
  final Business business;
  const CommentsSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: ReviewApiService(dio: Injector.get<Dio>()).getReviews(business.id),
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
                    onPressed: () {
                      // Recharger en rebuildant la page
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Aucun avis pour le moment.')),
          );
        }

        final reviews = snapshot.data!;
        final totalReviews = reviews.length;
        final avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En‑tête avec résumé des notes (optionnel, mais garde le style d'origine)
            Padding(
              padding: const EdgeInsets.all(16),
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
                        children: List.generate(5, (i) => Icon(
                          i < avgRating.floor()
                              ? Icons.star
                              : (i < avgRating ? Icons.star_half : Icons.star_border),
                          size: 16,
                          color: Colors.amber[700],
                        )),
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
                    onPressed: () {
                      // Ouvrir le formulaire d'écriture d'avis
                      _showReviewDialog(context, business);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Écrire un avis'),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Liste des avis avec ReviewCard
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReviewCard(review: review),
                );
              },
            ),
          ],
        );
      },
    );
  }
}






class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(review.userAvatar ?? '')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName ?? 'Anonyme'),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                                (i) => Icon(
                              i < review.rating ? Icons.star : Icons.star_border,
                              size: 12,
                              color: Colors.amber[700],
                            ),
                          ),
                          const SizedBox(width: 8),
                          //Text(_formatDate(review.date), style: Theme.of(context).textTheme.bodySmall,),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "Il y a $weeks semaine${weeks > 1 ? 's' : ''}";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}

void _showReviewDialog(BuildContext context, Business business) async {
  final authState = context.read<AuthBloc>().state;
  if (authState is! AuthAuthenticated) {
    context.go('/login');
    return;
  }

  int rating = 5;
  final commentController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Donner votre avis sur ${business.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber),
                    onPressed: () => setStateDialog(() => rating = index + 1),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Votre commentaire (optionnel)',
                  labelStyle: TextStyle(color: AppColors.surface),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                try {
                  final service = ReviewApiService(dio: Injector.get<Dio>());
                  await service.submitReview(business.id, authState.user.id, rating, commentController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Merci pour votre avis !')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    ),
  );
}