import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shows [AuthRequiredCard] in the app's shared bottom sheet.
///
/// Call this whenever a guest attempts an action that needs an account
/// (reservation, checkout, review, ...) instead of navigating to `/login`
/// directly — browsing itself must never require a login, only actions do.
Future<void> showAuthRequiredCard(
  BuildContext context, {
  String message = 'Connectez-vous pour continuer cette action.',
}) {
  return showCustomBottomSheet(
    context: context,
    child: AuthRequiredCard(message: message),
  );
}

/// Shared "you need an account" card. Import this instead of writing a new
/// login prompt inline — see AGENTS.md rule on reusing existing components.
class AuthRequiredCard extends StatelessWidget {
  const AuthRequiredCard({
    super.key,
    this.message = 'Connectez-vous pour continuer cette action.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimens.PADDING_16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        AppDimens.spacerMedium,
        Text(
          'Connexion requise',
          style: AppFonts.titleMedium,
          textAlign: TextAlign.center,
        ),
        AppDimens.spacerSmall,
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
        AppDimens.spacerLarge,
        CustomButton(
          text: 'Se connecter',
          onPressed: () {
            Navigator.of(context).pop();
            context.push('/login');
          },
        ),
        AppDimens.spacerSmall,
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Plus tard'),
        ),
      ],
    );
  }
}
