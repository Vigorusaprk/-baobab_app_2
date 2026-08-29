import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
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
  final rated = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RateOfferSheet(
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimens.bottomSheet),
            topRight: Radius.circular(AppDimens.bottomSheet),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.offerName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppDimens.spacerSmall,
            Text(
              'Votre note aide les autres clients à choisir.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            AppDimens.spacerMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final value = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = value),
                  icon: Icon(
                    value <= _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: OtherTheme.of(context).rating,
                    size: 34,
                  ),
                );
              }),
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
            AppDimens.spacerSmall,
          ],
        ),
      ),
    );
  }
}
