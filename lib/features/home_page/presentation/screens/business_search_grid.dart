import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/business_card.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'business_search_row.dart';

/// Grille de commerces paginée pour l'écran de recherche.
class BusinessSearchGrid extends StatelessWidget {
  const BusinessSearchGrid({
    super.key,
    required this.businesses,
    required this.scroll,
    required this.loadingMore,
    required this.onRefresh,
  });

  final List<Business> businesses;
  final ScrollController scroll;
  final bool loadingMore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final rows = (businesses.length + 1) ~/ 2;
    return CustomRefresh(
      key: const ValueKey('resultats'),
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scroll,
        padding: AppDimens.appPadding.copyWith(
          top: AppDimens.small,
          bottom: AppDimens.large,
        ),
        itemCount: rows + (loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, row) => row >= rows
            ? Skeletonizer(
                enabled: true,
                child: Row(
                  children: [
                    Expanded(child: BusinessCardSkeleton.tile()),
                    SizedBox(width: 12),
                    Expanded(child: BusinessCardSkeleton.tile()),
                  ],
                ),
              )
            : BusinessSearchRow(
                left: businesses[row * 2],
                right: row * 2 + 1 < businesses.length
                    ? businesses[row * 2 + 1]
                    : null,
              ),
      ),
    );
  }
}
