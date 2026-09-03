import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_cover.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/common/responsive_container.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Le squelette de la fiche commerce.
///
/// Il suit l'ordre réel de la page depuis la refonte : la photo, l'identité,
/// le filtre, les offres en rangées, puis la présentation, les horaires, les
/// commodités et les avis. Il imitait des carrousels d'offres et une photo
/// encadrée de 280 px : la page ne les a plus, et un squelette d'une autre
/// forme que son contenu fait sauter la page au moment où les données
/// arrivent.
class BusinessDetailSkeleton extends StatelessWidget {
  const BusinessDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _CoverSkeleton()),
        const SliverToBoxAdapter(child: _IdentitySkeleton()),
        const SliverToBoxAdapter(child: _LensSkeleton()),
        SliverToBoxAdapter(
          child: Column(
            children: const [
              _OfferRowSkeleton(),
              _OfferRowSkeleton(),
              _OfferRowSkeleton(),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: ResponsiveContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 24),
                _AboutSectionSkeleton(),
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

/// La photo, pleine largeur et sans cadre : c'est ainsi qu'elle arrive.
class _CoverSkeleton extends StatelessWidget {
  const _CoverSkeleton();

  @override
  Widget build(BuildContext context) {
    return Bone(
      width: double.infinity,
      height: BusinessCover.height + MediaQuery.paddingOf(context).top,
    );
  }
}

/// Le nom, la ligne de catégorie, l'étiquette d'horaire, les deux boutons.
class _IdentitySkeleton extends StatelessWidget {
  const _IdentitySkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      transform: Matrix4.translationValues(0, -14, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius16),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(width: 210, style: theme.textTheme.headlineSmall!),
          AppDimens.spacerSmall,
          Bone.text(width: 250, style: theme.textTheme.bodySmall!),
          AppDimens.spacerMedium,
          const Bone(width: 150, height: 26, uniRadius: 13),
          AppDimens.spacerMedium,
          const Row(
            children: [
              Expanded(child: Bone.button(height: AppDimens.touchTarget)),
              AppDimens.spacerSmallWidth,
              Expanded(child: Bone.button(height: AppDimens.touchTarget)),
            ],
          ),
        ],
      ),
    );
  }
}

/// La rangée de filtres.
class _LensSkeleton extends StatelessWidget {
  const _LensSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.appPaddingValue,
        AppDimens.small,
        AppDimens.appPaddingValue,
        AppDimens.small,
      ),
      child: Row(
        spacing: 6,
        children: [
          Bone(width: 86, height: 36, uniRadius: 18),
          Bone(width: 108, height: 36, uniRadius: 18),
          Bone(width: 92, height: 36, uniRadius: 18),
        ],
      ),
    );
  }
}

/// Une offre en rangée : vignette carrée, deux lignes, un prix.
class _OfferRowSkeleton extends StatelessWidget {
  const _OfferRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.appPaddingValue,
        0,
        AppDimens.appPaddingValue,
        AppDimens.small + 2,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
        ),
        padding: const EdgeInsets.all(AppDimens.small + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Bone(width: 74, height: 74, uniRadius: AppDimens.small),
            AppDimens.spacerMediumWidth,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(width: 170, style: theme.textTheme.titleSmall!),
                  AppDimens.spacerMini,
                  Bone.text(width: 220, style: theme.textTheme.bodySmall!),
                  AppDimens.spacerSmall,
                  Bone.text(width: 70, style: theme.textTheme.labelLarge!),
                ],
              ),
            ),
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
        Bone.text(width: 100, style: Theme.of(context).textTheme.titleMedium!),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Bone.multiText(
            lines: 3,
            style: Theme.of(context).textTheme.bodyMedium!,
          ),
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
        Bone.text(
          width: titleWidth,
          style: Theme.of(context).textTheme.titleMedium!,
        ),
        const SizedBox(height: 12),
        const Bone(width: double.infinity, height: 90, uniRadius: 20),
      ],
    );
  }
}

/// Mirrors [BusinessSpecificSection] : une grappe de badges « Commodités ».
class _SpecificSectionSkeleton extends StatelessWidget {
  const _SpecificSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.text(width: 180, style: Theme.of(context).textTheme.titleMedium!),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Bone(width: 110, height: 34, uniRadius: 17),
            Bone(width: 90, height: 34, uniRadius: 17),
            Bone(width: 130, height: 34, uniRadius: 17),
          ],
        ),
      ],
    );
  }
}

/// La forme de la section d'avis : le bandeau de note, puis deux avis en
/// rail. Publique pour que [RestaurantReview] la réutilise pendant que ses
/// propres avis chargent.
///
/// Elle imitait des cartes à avatar rond : les avis suivent un rail depuis la
/// refonte, et un squelette d'une autre forme que son contenu fait sauter la
/// page.
class ReviewSectionSkeleton extends StatelessWidget {
  const ReviewSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius20),
            color: theme.colorScheme.surfaceContainerLowest,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Bone.text(width: 34, style: theme.textTheme.headlineMedium!),
                  const Bone(width: 84, height: 16, uniRadius: 4),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Bone.text(width: 24, style: theme.textTheme.titleMedium!),
                  Bone.text(width: 30, style: theme.textTheme.bodySmall!),
                ],
              ),
              const Bone.button(
                width: 140,
                height: AppDimens.touchTarget,
                uniRadius: AppDimens.borderRadiusSmallButton,
              ),
            ],
          ),
        ),
        AppDimens.spacerMedium,
        const _ReviewRailSkeleton(),
        const _ReviewRailSkeleton(),
      ],
    );
  }
}

/// Un avis en rail : le filet, le nom, la note, la date, deux lignes.
class _ReviewRailSkeleton extends StatelessWidget {
  const _ReviewRailSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.medium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Bone(width: 2, height: 54),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Bone.text(width: 90, style: theme.textTheme.bodyMedium!),
                    AppDimens.spacerSmallWidth,
                    const Bone(width: 62, height: 12, uniRadius: 4),
                    const Spacer(),
                    Bone.text(width: 46, style: theme.textTheme.labelSmall!),
                  ],
                ),
                AppDimens.spacerMini,
                Bone.multiText(lines: 2, style: theme.textTheme.bodySmall!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
