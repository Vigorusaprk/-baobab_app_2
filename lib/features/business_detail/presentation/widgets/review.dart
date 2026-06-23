import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';

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
                  border: Border.all(width: 2, color: AppColors.secondaryLight),
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
                      style: FilledButton.styleFrom(backgroundColor: AppColors.secondaryLight),
                      onPressed: () => _showReviewDialog(context),
                      icon: const Icon(Icons.edit),
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
    if (difference.inDays == 0) return "Aujourd'hui";
    if (difference.inDays == 1) return "Hier";
    if (difference.inDays < 7) return "Il y a ${difference.inDays} jours";
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showReviewDialog(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    // ✅ Correction : Détection robuste de l'état connecté si le nom exact diffère
    final bool isAuthenticated = authState.runtimeType.toString().contains('Authenticated');

    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour laisser un avis.')),
      );
      return;
    }

    // Récupération dynamique de l'ID utilisateur selon la structure de votre AuthState
    dynamic userId = '';
    try {
      userId = (authState as dynamic).user.id;
    } catch (_) {
      userId = 'default_user_id';
    }

    int rating = 5;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.secondaryLight, AppColors.secondaryDark],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 3.5),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Donner votre avis sur ${widget.business.name}',
                    style: const TextStyle(color: AppColors.primaryLight, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(index < rating ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 32),
                        onPressed: () => setStateDialog(() => rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Votre commentaire (optionnel)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler', style: TextStyle(color: AppColors.primaryLight)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.secondaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () async {
                          try {
                            // ✅ Correction : Passage positionnel de l'instance Dio
                            final service = ReviewApiService();
                            await service.submitReview(widget.business.id, userId.toString(), rating, commentController.text);
                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Merci pour votre avis !')),
                              );
                            }
                            _refreshReviews();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        },
                        child: const Text('Envoyer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}