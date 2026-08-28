import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/core/widgets/custom_loading.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

/// Affiche la boîte de dialogue "Écrire un avis" pour un business donné.
///
/// ✅ Mécanique alignée sur `showSpaReservationModal` : un widget dédié
/// (`WriteReviewModal`) est poussé via `showModalBottomSheet`, ce qui donne
/// la même transition "surgit du bas" que les autres modales de l'app.
/// Le design de la carte (radius 24 sur les 4 coins, bordure, largeur 85%)
/// reste strictement identique à l'original.
Future<void> showWriteReviewDialog(
    BuildContext context,
    Business business, {
      required VoidCallback onSubmitted,
    }) async {
  final sessionUser = SessionService.instance.currentUser;

  if (sessionUser == null) {
    showAuthRequiredCard(
      context,
      message: 'Connectez-vous pour laisser un avis.',
    );
    return;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    barrierColor: Colors.black54,
    builder: (modalContext) => WriteReviewModal(
      business: business,
      userId: sessionUser.id,
      onSubmitted: onSubmitted,
    ),
  );
}

class WriteReviewModal extends StatefulWidget {
  final Business business;
  final dynamic userId;
  final VoidCallback onSubmitted;

  const WriteReviewModal({
    Key? key,
    required this.business,
    required this.userId,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  State<WriteReviewModal> createState() => _WriteReviewModalState();
}

class _WriteReviewModalState extends State<WriteReviewModal> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final service = ReviewApiService();
      await service.submitReview(
        widget.business.id,
        widget.userId.toString(),
        _rating,
        _commentController.text,
      );
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merci pour votre avis !')),
        );
      }
      widget.onSubmitted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Remonte le contenu au-dessus du clavier
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight:  Radius.circular(24)),
            border: Border.all(
              color: AppColors.white.withOpacity(0.4),
              width: 3.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Donner votre avis sur ${widget.business.name}',
                style: AppFonts.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setState(() => _rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Votre commentaire (optionnel)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.secondary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child:  Text(
                      'Annuler',
                      style: AppFonts.bodyLarge
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: AppTheme.silvaTheme.elevatedButtonTheme.style,
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CustomLoadingButton(
                            size: 22,
                            color: AppColors.white,
                          )
                        : const Text('Envoyer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}