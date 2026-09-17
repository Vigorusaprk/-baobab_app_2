part of 'business_sections.dart';

/// Squelette d'un [BusinessRail].
class BusinessRailSkeleton extends StatelessWidget {
  const BusinessRailSkeleton({
    super.key,
    required this.width,
    this.titleWidth = 110,
    this.count = 3,
  });

  final RailWidth width;
  final double titleWidth;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileWidth =
        (MediaQuery.sizeOf(context).width - AppDimens.appPaddingValue * 2) *
        width.fraction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimens.appPadding,
          child: Bone.text(
            width: titleWidth,
            style: theme.textTheme.titleSmall!,
          ),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: AppDimens.appPadding,
          child: Row(
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                SizedBox(
                  width: tileWidth,
                  child: const BusinessCardSkeleton.tile(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Squelette d'une [BusinessGrid] : deux tuiles par ligne, deux lignes.
class BusinessGridSkeleton extends StatelessWidget {
  const BusinessGridSkeleton({super.key, this.titleWidth = 130});

  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimens.appPadding,
          child: Bone.text(
            width: titleWidth,
            style: theme.textTheme.titleSmall!,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: AppDimens.appPadding,
          child: Column(
            children: [
              for (var row = 0; row < 2; row++) ...[
                if (row > 0) const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(child: BusinessCardSkeleton.tile()),
                    SizedBox(width: 12),
                    Expanded(child: BusinessCardSkeleton.tile()),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
