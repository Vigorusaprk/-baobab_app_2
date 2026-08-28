import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Mock de l'espace commerçant, affiché le temps que `get-merchant-space`
/// réponde.
///
/// Reprend le tableau de bord réel : la bannière de ce qui attend, la
/// grille des quatre chiffres, la carte du commerce et les raccourcis.
class MerchantSpaceSkeleton extends StatelessWidget {
  const MerchantSpaceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.appPaddingValue,
          AppDimens.appPaddingValue,
          AppDimens.appPaddingValue,
          100,
        ),
        children: [
          const _CardSkeleton(
            child: Row(
              children: [
                Bone.circle(size: 24),
                AppDimens.spacerMediumWidth,
                Expanded(child: Bone.multiText(lines: 1)),
              ],
            ),
          ),
          AppDimens.spacerMedium,
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: List.generate(4, (_) => const _StatCardSkeleton()),
          ),
          AppDimens.spacerLarge,
          Bone.text(width: 120, style: AppFonts.titleMedium),
          AppDimens.spacerSmall,
          _CardSkeleton(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Bone.text(width: 160, style: AppFonts.bodyLarge),
                AppDimens.spacerMini,
                Bone.text(width: 200, style: AppFonts.bodySmall),
                AppDimens.spacerSmall,
                Bone.text(width: 110, style: AppFonts.bodySmall),
              ],
            ),
          ),
          AppDimens.spacerLarge,
          for (var i = 0; i < 3; i++) ...[
            _CardSkeleton(
              child: Row(
                children: [
                  const Bone.circle(size: 22),
                  AppDimens.spacerMediumWidth,
                  Expanded(
                    child: Bone.text(width: 150, style: AppFonts.bodyLarge),
                  ),
                ],
              ),
            ),
            AppDimens.spacerSmall,
          ],
        ],
      ),
    );
  }
}

/// Mirrors [MerchantCard] : le conteneur blanc arrondi commun à l'espace.
class _CardSkeleton extends StatelessWidget {
  final Widget child;

  const _CardSkeleton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.smallCardBorderRadius),
      ),
      child: child,
    );
  }
}

/// Mirrors [MerchantStatCard] : icône, chiffre, libellé.
class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimens.allPadding12,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.smallCardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Bone.circle(size: 20),
          AppDimens.spacerSmall,
          Bone.text(width: 60, style: AppFonts.titleMedium),
          AppDimens.spacerMini,
          Bone.text(width: 90, style: AppFonts.bodySmall),
        ],
      ),
    );
  }
}
