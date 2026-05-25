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
    _reviewsFuture = ReviewApiService(dio: Injector.get<Dio>())
        .getReviews(widget.business.id);
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
            // En-tête : note moyenne, nombre d'avis, bouton d'ajout
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: AppColors.primary),
                borderRadius: BorderRadius.circular(100)
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                          children: _buildStars(avgRating, 16),
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
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary
                      ),
                      onPressed: () => _showReviewDialog(context),
                      icon:  Icon(Icons.edit),
                      label: Text('Écrire un avis',),
                    ),
                  ],
                ),
              ),
            ),

            // Liste des avis
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
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
                              child: const Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(review.userName ?? 'Anonyme', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Row(
                                    children: [
                                      ..._buildStars(review.rating.toDouble(), 12),
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
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildStars(double rating, double size) {
    final stars = <Widget>[];
    for (int i = 0; i < 5; i++) {
      if (i < rating.floor()) {
        stars.add(Icon(Icons.star, size: size, color: Colors.amber[700]));
      } else if (i < rating) {
        stars.add(Icon(Icons.star_half, size: size, color: Colors.amber[700]));
      } else {
        stars.add(Icon(Icons.star_border, size: size, color: Colors.amber[700]));
      }
    }
    return stars;
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

  void _showReviewDialog(BuildContext context) async {
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
            title: Text('Donner votre avis sur ${widget.business.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber),
                      onPressed: () => setStateDialog(() => rating = index + 1),
                    );
                  }),
                ),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Votre commentaire (optionnel)',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final service = ReviewApiService(dio: Injector.get<Dio>());
                    await service.submitReview(
                      widget.business.id,
                      authState.user.id,
                      rating,
                      commentController.text,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Merci pour votre avis !')),
                    );
                    _refreshReviews(); // Recharge la liste
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
}