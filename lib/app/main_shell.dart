import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

/// Single Scaffold for the app's main navigation: bottom nav bar + the
/// per-branch app bar (Home/Settings), hosting the StatefulNavigationShell's
/// four branches (Home, Explore, Orders, Settings). Each branch screen only
/// provides body content — no Scaffold/AppBar of its own.
class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<ValueNotifier<int>> branchStackDepth;

  const MainShell({
    super.key,
    required this.navigationShell,
    required this.branchStackDepth,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _homeBranch = 0;
  static const int _settingsBranch = 3;

  bool _wasAuthenticated = false;

  final List<List<String>> _svgPaths = const [
    [
      'assets/icons/home-angle-2-svgrepo-com (2).svg',
      'assets/icons/home-angle-2-svgrepo-com (3).svg',
    ],
    [
      'assets/icons/explore-outline.svg',
      'assets/icons/explore-svgrepo-com (1).svg',
    ],
    ['assets/icons/order.svg', 'assets/icons/order-svgrepo.svg'],
    [
      'assets/icons/setting-gear-svgrepo-com.svg',
      'assets/icons/setting-svgrepo-com.svg',
    ],
  ];

  final List<String> _labels = const [
    'Accueil',
    'Explorer',
    'Mes activités',
    'Paramètres',
  ];

  @override
  void initState() {
    super.initState();
    _wasAuthenticated =
        context.read<AuthSessionCubit>().state is AuthSessionAuthenticated;
  }

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _handleAuthSessionChanged(AuthSessionState state) {
    final isAuthenticated = state is AuthSessionAuthenticated;
    if (_wasAuthenticated && !isAuthenticated) {
      // Signed out: don't leave the user stranded on a nested page inside
      // a branch (e.g. deep in Settings) behind a hidden bottom bar.
      for (final depth in widget.branchStackDepth) {
        depth.value = 0;
      }
      widget.navigationShell.goBranch(_homeBranch, initialLocation: true);
    }
    _wasAuthenticated = isAuthenticated;
  }

  PreferredSizeWidget? _appBarFor(int currentBranch) {
    switch (currentBranch) {
      // Pas d'AppBar sur l'accueil : HomeSliverHeader en tient lieu. Il
      // défile avec la page puis reste épinglé en version compacte, ce
      // qu'une AppBar de Scaffold ne permet pas.
      case _settingsBranch:
        return SettingsAppBar();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentBranch = widget.navigationShell.currentIndex;

    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listener: (context, state) => _handleAuthSessionChanged(state),
      child: ValueListenableBuilder<int>(
        valueListenable: widget.branchStackDepth[currentBranch],
        builder: (context, depth, _) {
          final shouldShowBar = depth == 0;
          final shouldShowAppBar = depth == 0;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: shouldShowAppBar ? _appBarFor(currentBranch) : null,
            body: widget.navigationShell,
            bottomNavigationBar: shouldShowBar
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                            isSelected: currentBranch == index,
                          );
                        }),
                      ),
                    ),
                  )
                : null,
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
    required bool isSelected,
  }) {
    final Color selectedBgColor = AppColors.primary;
    final Color selectedIconColor = AppColors.white;
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
                  width: 20,
                  height: 20,
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
                AppDimens.spacerSmallWidth,
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: selectedIconColor,
                    fontWeight: FontWeight.w600,
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
