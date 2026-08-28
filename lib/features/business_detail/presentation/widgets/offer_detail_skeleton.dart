import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Mock de la fiche d'une offre, à envelopper dans un [Skeletonizer].
///
/// Reprend l'ordre réel de la page : visuel, nom, prix, description, faits,
/// carte du commerçant, puis le rail des autres offres. Les avis n'y sont
/// pas — beaucoup d'offres n'en ont aucun, et annoncer une section qui ne
/// viendra pas fait sauter la page au moment du remplacement.
class OfferDetailSkeleton extends StatelessWidget {
  const OfferDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const Bone(
          height: 240,
          width: double.infinity,
          borderRadius: BorderRadius.zero,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.appPaddingValue,
            AppDimens.appPaddingValue,
            AppDimens.appPaddingValue,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.text(words: 3, style: AppFonts.titleMedium),
              AppDimens.spacerSmall,
              Bone.text(width: 80, style: AppFonts.bodyLarge),
              AppDimens.spacerMedium,
              Bone.multiText(lines: 3, style: AppFonts.bodyMedium),
              AppDimens.spacerMedium,
              for (var i = 0; i < 2; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Bone.circle(size: 18),
                      AppDimens.spacerSmallWidth,
                      Bone.text(width: 160, style: AppFonts.bodyMedium),
                    ],
                  ),
                ),
              AppDimens.spacerSmall,
              Bone.text(width: 100, style: AppFonts.titleMedium),
              AppDimens.spacerSmall,
              const _MerchantCardSkeleton(),
            ],
          ),
        ),
        AppDimens.spacerLarge,
        const OffersCarouselSkeleton(titleWidth: 170, cardCount: 2),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Mirrors [OfferMerchantCard] : vignette carrée, nom, note.
class _MerchantCardSkeleton extends StatelessWidget {
  const _MerchantCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppDimens.cardBorderRadiusAll,
      ),
      child: Row(
        children: [
          const Bone(width: 48, height: 48, uniRadius: AppDimens.radius12),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Bone.text(width: 140, style: AppFonts.bodyLarge),
                AppDimens.spacerMini,
                Bone.text(width: 90, style: AppFonts.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
