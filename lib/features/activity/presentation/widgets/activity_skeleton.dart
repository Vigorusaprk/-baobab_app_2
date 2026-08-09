import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Skeleton list shown (already wrapped in [Skeletonizer]) while
/// [ActivityScreen] is loading the current tab's data. [itemSkeleton]
/// picks which card shape to repeat — [OrderCardSkeleton] or
/// [ReservationCardSkeleton].
class ActivityListSkeleton extends StatelessWidget {
  final Widget itemSkeleton;

  const ActivityListSkeleton({super.key, required this.itemSkeleton});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => itemSkeleton,
      ),
    );
  }
}

/// Mirrors [OrderCard]: icon box + name/type pill + status pill, date,
/// a couple of item rows, then a total footer.
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Bone(width: 50, height: 50, uniRadius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Bone.text(width: 140, style: AppFonts.titleMedium),
                      const SizedBox(height: 8),
                      const Bone(width: 70, height: 20, uniRadius: 12),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Bone(width: 60, height: 24, uniRadius: 12),
              ],
            ),
            const SizedBox(height: 12),
            Bone.text(width: 120, style: AppFonts.bodySmall),
            const SizedBox(height: 12),
            ...List.generate(
              2,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Bone.text(width: 130, style: AppFonts.bodyMedium),
                    Bone.text(width: 40, style: AppFonts.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.small,
                vertical: AppDimens.small,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppDimens.radius16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Bone.text(width: 40, style: AppFonts.bodyMedium),
                  Bone.text(width: 60, style: AppFonts.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors [ReservationCard]: bordered icon box + name/type pill, status
/// pill + delete icon, a details block, then a total footer.
class ReservationCardSkeleton extends StatelessWidget {
  const ReservationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.medium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Bone(
                  width: 50,
                  height: 50,
                  uniRadius: AppDimens.radius12,
                ),
                const SizedBox(width: AppDimens.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Bone.text(width: 160, style: AppFonts.titleMedium),
                      const SizedBox(height: AppDimens.small),
                      Row(
                        children: [
                          const Bone(
                            width: 70,
                            height: 22,
                            uniRadius: AppDimens.radius8,
                          ),
                          const SizedBox(width: AppDimens.small),
                          Expanded(
                            child: Bone.text(
                              width: 100,
                              style: AppFonts.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Bone(width: 60, height: 24, uniRadius: AppDimens.radius10),
                    SizedBox(height: AppDimens.small),
                    Bone.circle(size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimens.medium),
            const Bone(
              width: double.infinity,
              height: 40,
              uniRadius: AppDimens.radius12,
            ),
            const SizedBox(height: AppDimens.medium),
            Container(
              padding: const EdgeInsets.all(AppDimens.medium),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimens.radius12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Bone.text(width: 40, style: AppFonts.bodyMedium),
                  Bone.text(width: 60, style: AppFonts.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
