import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool showBottomBar;
  final List<ValueNotifier<int>> branchStackDepth;

  const MainScreen({
    super.key,
    required this.navigationShell,
    required this.showBottomBar,
    required this.branchStackDepth,
  });

  final List<List<String>> _svgPaths = const [
    ['assets/icons/home-angle-2-svgrepo-com (2).svg', 'assets/icons/home-angle-2-svgrepo-com (3).svg'],
    ['assets/icons/explore-outline.svg', 'assets/icons/explore-svgrepo-com (1).svg'],
    ['assets/icons/order.svg', 'assets/icons/order-svgrepo.svg'],
    ['assets/icons/setting-gear-svgrepo-com.svg', 'assets/icons/setting-svgrepo-com.svg'],
  ];

  final List<String> _labels = const [
    'Home',
    'Explore',
    'Mes activites',
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
    return ValueListenableBuilder<int>(
      valueListenable: branchStackDepth[navigationShell.currentIndex],
      builder: (context, depth, _) {
        final shouldShowBar = showBottomBar && depth == 0;

        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          body: navigationShell,
          bottomNavigationBar: shouldShowBar
              ? Container(
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    height: 70,
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
                )
              : null,
        );
      },
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
    final Color selectedIconColor = AppColors.primary50;
    final Color unselectedIconColor = AppColors.primary;

    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
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
                    fontFamily: "Poppins",
                    color: selectedIconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
