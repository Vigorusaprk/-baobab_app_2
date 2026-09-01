import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/rating_stars.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:flutter/material.dart';

/// Notation de ce qui a été réellement consommé.
///
/// On note une **offre**, pas un commerce : la note du commerçant est la
/// moyenne des avis reçus par ses offres. Un client qui a mangé un plat
/// médiocre chez un bon restaurateur note le plat, et c'est ce plat qui
/// perd des places dans « Découvrir ».
Future<bool> showRateOfferSheet(
  BuildContext context, {
  required String businessId,
  required String offerId,
  required String offerName,
}) async {
  final rated = await showCustomBottomSheet<bool>(
    context: context,
    title: offerName,
    child: _RateOfferSheet(
      businessId: businessId,
      offerId: offerId,
      offerName: offerName,
    ),
  );
  return rated ?? false;
}

class _RateOfferSheet extends StatefulWidget {
  final String businessId;
  final String offerId;
  final String offerName;

  const _RateOfferSheet({
    required this.businessId,
    required this.offerId,
    required this.offerName,
  });

  @override
  State<_RateOfferSheet> createState() => _RateOfferSheetState();
}

class _RateOfferSheetState extends State<_RateOfferSheet> {
  final _comment = TextEditingController();
  int _rating = 5;
  bool _isSending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSending = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ReviewApiService().submitReview(
        widget.businessId,
        '',
        _rating,
        _comment.text.trim().isEmpty ? null : _comment.text.trim(),
        offerId: widget.offerId,
      );
      if (!mounted) return;
      navigator.pop(true);
      messenger.showSnackBar(
        const SnackBar(content: Text('Merci pour votre avis !')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Votre avis n\'a pas pu être envoyé.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cadre, coins, marges et remontée au-dessus du clavier appartiennent
    // désormais à la feuille partagée ; le titre aussi.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Votre note aide les autres clients à choisir.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerMedium,
        RatingStars(
          rating: _rating,
          onChanged: (v) => setState(() => _rating = v),
        ),
        AppDimens.spacerMedium,
        CustomTextFormField(
          controller: _comment,
          hintText: 'Un mot sur votre expérience (facultatif)',
        ),
        AppDimens.spacerLarge,
        CustomButton(
          text: 'Envoyer mon avis',
          isLoading: _isSending,
          onPressed: _isSending ? () {} : _submit,
        ),
      ],
    );
  }
}
