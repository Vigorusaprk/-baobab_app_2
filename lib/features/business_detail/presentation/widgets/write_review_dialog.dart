import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:baobabe_0_2/core/widgets/rating_stars.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

/// « Écrire un avis » sur un commerce.
///
/// La feuille était montée à la main : `showModalBottomSheet` direct, cadre
/// et coins redessinés, `TextField` brut, deux boutons écrits sur place. Elle
/// passe maintenant par [showCustomBottomSheet], qui apporte le flou, la
/// poignée, la croix de fermeture et la remontée au-dessus du clavier.
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

  await showCustomBottomSheet<void>(
    context: context,
    title: 'Donner votre avis sur ${business.name}',
    child: WriteReviewModal(
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
    super.key,
    required this.business,
    required this.userId,
    required this.onSubmitted,
  });

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
            content: const Text("Votre avis n'a pas pu être envoyé."),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDimens.spacerSmall,
        RatingStars(
          rating: _rating,
          onChanged: (value) => setState(() => _rating = value),
          size: 32,
        ),
        AppDimens.spacerMedium,
        CustomTextFormField(
          controller: _commentController,
          hintText: 'Votre commentaire (optionnel)',
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        AppDimens.spacerLarge,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomActionButton(
              label: 'Annuler',
              tone: ActionButtonTone.tonal,
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            ),
            AppDimens.spacerSmallWidth,
            CustomActionButton(
              label: 'Envoyer',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ],
    );
  }
}
