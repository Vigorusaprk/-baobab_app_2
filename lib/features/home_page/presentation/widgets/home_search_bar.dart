import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_card.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  /// Hauteur intrinsèque de la barre : padding vertical du champ
  /// (2 × [AppDimens.small]) + hauteur de l'icône de recherche (25).
  ///
  /// Exposée pour que [HomeSliverHeader], qui doit déclarer des extents
  /// fixes, réserve exactement la bonne place. Toute modification de la
  /// hauteur du champ ci-dessous doit être répercutée ici.
  static const double height = AppDimens.small * 2 + 25;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.appPadding,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                final searchBloc = context.read<SearchBloc>();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: searchBloc,
                      child: const SearchPage(),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.medium,
                  vertical: AppDimens.small,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/explore-outline.svg',
                      height: 25,
                      width: 25,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: AppDimens.medium),
                    const Expanded(
                      child: Text(
                        "Restaurant, concert, cosmétique…",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: AppDimens.medium),

          GestureDetector(
            onTap: () {
              context.pushNamed('budgetFinder');
            },
            child: CustomCard(
              color: Theme.of(context).primaryColor,
              child: SvgPicture.asset(
                'assets/icons/filter.svg',
                height: 20,
                width: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
