import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/common/responsive_container.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offer_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Full mock of the business detail page, shown (wrapped in [Skeletonizer])
/// while [BusinessDetailBloc] is still loading its first response.
///
/// Il suit l'ordre réel de la page : à propos, catalogue, contact, horaires,
/// commodités, avis. Un squelette qui annonce une rangée de boutons d'action
/// alors que la page n'en a plus promet quelque chose qui n'arrivera pas.
class BusinessDetailSkeleton extends StatelessWidget {
  const BusinessDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const _HeroSkeleton(),
        SliverToBoxAdapter(
          child: ResponsiveContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 24),
                _AboutSectionSkeleton(),
                SizedBox(height: 24),
                _OffersSectionSkeleton(),
                SizedBox(height: 24),
                _BlockSkeleton(titleWidth: 150),
                SizedBox(height: 24),
                _BlockSkeleton(titleWidth: 170),
                SizedBox(height: 24),
                _SpecificSectionSkeleton(),
                SizedBox(height: 24),
                ReviewSectionSkeleton(),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Mirrors [BusinessDetailAppBar]'s expanded hero image + circular back
/// and favorite buttons.
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 55, 16, 0),
        child: Stack(
          children: const [
            Bone(width: double.infinity, height: 280, uniRadius: 28),
            Positioned(top: 8, left: 8, child: Bone.circle(size: 36)),
            Positioned(top: 8, right: 8, child: Bone.circle(size: 36)),
          ],
        ),
      ),
    );
  }
}

/// Mirrors [BusinessAboutSection]: a section title over a description card.
class _AboutSectionSkeleton extends StatelessWidget {
  const _AboutSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.text(width: 100, style: AppFonts.titleMedium),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Bone.multiText(lines: 3, style: AppFonts.bodyMedium),
        ),
      ],
    );
  }
}

/// Un titre de section suivi d'un bloc plein : la forme partagée du contact
/// et des horaires.
class _BlockSkeleton extends StatelessWidget {
  final double titleWidth;

  const _BlockSkeleton({required this.titleWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.text(width: titleWidth, style: AppFonts.titleMedium),
        const SizedBox(height: 12),
        const Bone(width: double.infinity, height: 90, uniRadius: 20),
      ],
    );
  }
}

/// Mirrors [BusinessOffersSection]: un titre puis un carrousel de cartes
/// d'offre.
class _OffersSectionSkeleton extends StatelessWidget {
  const _OffersSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.text(width: 140, style: AppFonts.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) =>
                const SizedBox(width: 190, child: OfferCardSkeleton()),
          ),
        ),
      ],
    );
  }
}

/// Mirrors [BusinessSpecificSection]: a couple of item rows (menu items,
/// rooms, vehicles, movies... — shape varies by business type but is
/// consistently icon + title + subtitle).
class _SpecificSectionSkeleton extends StatelessWidget {
  const _SpecificSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 1 ? 0 : 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Bone(width: 64, height: 64, uniRadius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Bone.text(width: 140, style: AppFonts.titleMedium),
                      const SizedBox(height: 6),
                      Bone.text(width: 80, style: AppFonts.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Mirrors [RestaurantReview]: the rating summary bar + a couple of
/// [ReviewListItem]-shaped rows (avatar, name, stars, comment). Public so
/// [RestaurantReview] itself can reuse it while its own reviews future is
/// still pending.
class ReviewSectionSkeleton extends StatelessWidget {
  const ReviewSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Bone.text(width: 30, style: AppFonts.bodyLarge),
                  const SizedBox(height: 6),
                  const Bone(width: 70, height: 14, uniRadius: 4),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Bone.text(width: 24, style: AppFonts.bodyMedium),
                  const SizedBox(height: 6),
                  Bone.text(width: 30, style: AppFonts.bodySmall),
                ],
              ),
              const Bone.button(width: 120, height: 36, uniRadius: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          2,
          (_) => Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Bone.circle(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Bone.text(width: 100, style: AppFonts.bodyMedium),
                          const SizedBox(height: 6),
                          const Bone(width: 90, height: 12, uniRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Bone.multiText(lines: 2, style: AppFonts.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
