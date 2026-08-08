import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Full mock of the Home tab's layout, shown (wrapped in [Skeletonizer])
/// while [BusinessBloc] is still loading its first page of data. Mirrors
/// the shape of every real section — [HomeSearchBar], `CategoryIcons`,
/// `BusinessPromoCarousel`, `PopularBusinessesSection`,
/// `BusinessCardsWidget` — using explicit [Bone] shapes so each part
/// reads clearly instead of a single generic spinner.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDimens.spacerSmall,
        const _SearchBarSkeleton(),
        AppDimens.spacerSmall,
        const _CategoryIconsSkeleton(),
        AppDimens.spacerSmall,
        const _SectionTitleSkeleton(),
        const SizedBox(height: 10),
        const _PromoCardSkeleton(),
        AppDimens.spacerSmall,
        const _SectionTitleSkeleton(),
        const SizedBox(height: 12),
        const _PopularRowSkeleton(),
        const SizedBox(height: 10),
        const _PopularRowSkeleton(),
        const SizedBox(height: 10),
        const _PopularRowSkeleton(),
        AppDimens.spacerSmall,
        const _SectionTitleSkeleton(),
        const SizedBox(height: 12),
        const _BusinessCardSkeleton(),
        const SizedBox(height: 100),
      ],
    );
  }
}

/// Mirrors [HomeSearchBar]: a search field bone + a filter button bone.
class _SearchBarSkeleton extends StatelessWidget {
  const _SearchBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.appPadding,
      child: Row(
        children: [
          const Expanded(child: Bone(height: 52, uniRadius: AppDimens.radius12)),
          AppDimens.spacerSmallWidth,
          const Bone(width: 52, height: 52, uniRadius: AppDimens.radius12),
        ],
      ),
    );
  }
}

/// Mirrors `CategoryIcons`: a horizontal row of circle-and-label cards.
class _CategoryIconsSkeleton extends StatelessWidget {
  const _CategoryIconsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? AppDimens.appPaddingValue : 8.0,
              right: index == 5 ? AppDimens.appPaddingValue : 8.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: SizedBox(
              width: 85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Bone.circle(size: 52),
                  const SizedBox(height: 10),
                  Bone.text(words: 1, style: AppFonts.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Mirrors the section header used by the promo carousel / popular list
/// (title + "Voir tout" link).
class _SectionTitleSkeleton extends StatelessWidget {
  const _SectionTitleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.large),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Bone.text(width: 120, style: AppFonts.titleMedium),
          Bone.text(width: 50, style: AppFonts.bodySmall),
        ],
      ),
    );
  }
}

/// Mirrors [BusinessPromoCard]: a colored banner block over a name +
/// subtitle + pill button footer.
class _PromoCardSkeleton extends StatelessWidget {
  const _PromoCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.large),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.cardBorderRadiusAll,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Bone(height: 125, width: double.infinity, borderRadius: BorderRadius.zero),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Bone.text(words: 2, style: AppFonts.titleMedium),
                        const SizedBox(height: 6),
                        Bone.text(words: 3, style: AppFonts.bodySmall),
                      ],
                    ),
                  ),
                  AppDimens.spacerMedium,
                  const Bone.button(width: 64, height: 36, uniRadius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors `_PopularBusinessRow`: an avatar circle + name + rating/tag row.
class _PopularRowSkeleton extends StatelessWidget {
  const _PopularRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.large),
      child: Container(
        padding: AppDimens.allPadding12,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppDimens.cardBorderRadiusAll,
        ),
        child: Row(
          children: [
            const Bone.circle(size: 45),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Bone.text(width: 140, style: AppFonts.titleMedium),
                  const SizedBox(height: 6),
                  Bone.text(width: 90, style: AppFonts.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors [BusinessCardWidget]: photo block + rating pill + name +
/// description, sized like the real carousel card.
class _BusinessCardSkeleton extends StatelessWidget {
  const _BusinessCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: SizedBox(
        height: 490,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimens.cardBorderRadiusAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimens.cardBorderRadius),
                    topRight: Radius.circular(AppDimens.cardBorderRadius),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const Positioned.fill(child: Bone()),
                      const Positioned(
                        top: 12,
                        right: 12,
                        child: Bone(width: 44, height: 24, uniRadius: 8),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(words: 2, style: AppFonts.titleMedium),
                    const SizedBox(height: 8),
                    Bone.multiText(lines: 2, style: AppFonts.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
