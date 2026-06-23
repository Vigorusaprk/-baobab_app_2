import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  // ⭐️ Définir les chemins des SVG pour chaque état et chaque icône
  // Format: [index][0] = outline, [index][1] = filled
  final List<List<String>> _svgPaths = const [
    ['assets/icons/home-angle-2-svgrepo-com (2).svg', 'assets/icons/home-angle-2-svgrepo-com (3).svg'],
    ['assets/icons/calendar-date-svgrepo-com.svg', 'assets/icons/calendar-date-svgrepo-com (1).svg'],
    ['assets/icons/order.svg', 'assets/icons/order-svgrepo.svg'], // Booking
    ['assets/icons/setting-gear-svgrepo-com.svg', 'assets/icons/setting-svgrepo-com.svg'],
  ];

  final List<String> _labels = const [
    'Home',
    'Reservation',
    'Commende',
    'Parametre',
  ];

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: navigationShell, // Affiche la branche courante
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
          color: AppColors.secondaryLight,
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
              isSelected: navigationShell.currentIndex == index,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required String svgOutlinePath,
        required String svgFilledPath,
        required String label,
        required int index,
        required bool isSelected,
      }) {
    final Color selectedBgColor = AppColors.primary;
    final Color selectedIconColor = AppColors.secondary;
    final Color unselectedIconColor = AppColors.primary;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                key: ValueKey<bool>(isSelected),
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
                  fontFamily: "Poppins", // Correction de la typo
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
  }
}