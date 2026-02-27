
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/favorites_page/presentation/screens/favorites_page_screen.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/home_page_screen.dart';
import 'package:baobabe_0_2/features/main/presentation/bloc/main_scree_event.dart';
import 'package:baobabe_0_2/features/main/presentation/bloc/main_screen_bloc.dart';
import 'package:baobabe_0_2/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class MainScreen extends StatelessWidget {
  final List<Widget> _pages = [
    const HomePageScreen(),
    const FavoritesPageScreen(),
    Container(),
    SettingsScreen(),
  ];

  // ⭐️ Définir les chemins des SVG pour chaque état et chaque icône
  // Format: [index][0] = outline, [index][1] = filled
  final List<List<String>> _svgPaths = [
    ['assets/icons/home-angle-2-svgrepo-com (2).svg', 'assets/icons/home-angle-2-svgrepo-com (3).svg'],    // Home
    ['assets/icons/calendar-date-svgrepo-com.svg', 'assets/icons/calendar-date-svgrepo-com (1).svg'],  // Ma classe
    ['assets/icons/phone-intercom-svgrepo-com.svg', 'assets/icons/phone-intercom-svgrepo-com.svg'], // Booking
    ['assets/icons/setting-gear-svgrepo-com.svg', 'assets/icons/setting-svgrepo-com.svg'],    // Parametre
  ];

  final List<String> _labels = [
    'Home',
    'Reservation',
    'Coupon',
    'Parametre',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainScreenBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            extendBody: true,
            backgroundColor: Colors.white,
            body: BlocBuilder<MainScreenBloc, int>(
              builder: (context, currentIndex) {
                if (currentIndex >= _pages.length) {
                  return _pages[0];
                }
                return _pages[currentIndex];
              },
            ),
            bottomNavigationBar: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              height: 70,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) {
                  return _buildNavItem(
                    context,
                    svgOutlinePath: _svgPaths[index][0],
                    svgFilledPath: _svgPaths[index][1],
                    label: _labels[index],
                    index: index,
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required String svgOutlinePath,
        required String svgFilledPath,
        required String label,
        required int index,
      }) {
    final Color selectedBgColor = Theme.of(context).colorScheme.surface;
    final Color selectedIconColor = AppColors.primary;
    final Color unselectedIconColor = Theme.of(context).colorScheme.surface;

    return BlocBuilder<MainScreenBloc, int>(
      builder: (context, currentIndex) {
        bool isSelected = currentIndex == index;

        return GestureDetector(
          onTap: () => context.read<MainScreenBloc>().add(TabChangeEvent(index)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: isSelected
                ? BoxDecoration(
              color: selectedBgColor,
              borderRadius: BorderRadius.circular(50),
            )
                : null,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 18 : 12,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ⭐️ Version avec AnimatedSwitcher pour une transition fluide
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    key: ValueKey<bool>(isSelected), // Important pour l'animation
                    width: 29,
                    height: 29,
                    child: SvgPicture.asset(
                      isSelected ? svgFilledPath : svgOutlinePath,
                      colorFilter: ColorFilter.mode(
                        isSelected ? selectedIconColor : unselectedIconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: "Poopins",
                      color: selectedIconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}