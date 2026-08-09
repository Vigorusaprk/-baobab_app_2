import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Full mock of [ProfilPage]'s loaded layout, shown (wrapped in
/// [Skeletonizer]) while [SettingsCubit] is still loading the user's
/// profile: avatar + the three profile field rows + the edit button.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Bone.circle(size: 100),
          const SizedBox(height: 24),
          const _ProfileFieldSkeleton(),
          const SizedBox(height: 16),
          const _ProfileFieldSkeleton(),
          const SizedBox(height: 16),
          const _ProfileFieldSkeleton(),
          const SizedBox(height: 32),
          const Bone.button(width: double.infinity, height: 54, uniRadius: 16),
        ],
      ),
    );
  }
}

/// Mirrors `_buildProfileField`: leading icon + label line + value line.
class _ProfileFieldSkeleton extends StatelessWidget {
  const _ProfileFieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Bone.circle(size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Bone.text(width: 90, style: AppFonts.bodySmall),
                const SizedBox(height: 6),
                Bone.text(width: 150, style: AppFonts.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
