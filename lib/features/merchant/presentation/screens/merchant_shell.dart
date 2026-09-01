import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/screens/merchant_dashboard_screen.dart';
import 'package:baobabe_0_2/features/merchant/presentation/screens/merchant_inbox_screen.dart';
import 'package:baobabe_0_2/features/merchant/presentation/screens/merchant_offers_screen.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_space_skeleton.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// L'application vue par un commerçant.
///
/// Écran plein, avec sa propre barre de navigation : le commerçant ne
/// navigue plus dans un catalogue, il gère un commerce. Les deux mondes ne
/// partagent donc pas leur coquille — celle du client (MainShell) reste
/// atteignable depuis le tableau de bord, pour qu'un commerçant puisse
/// aussi commander ailleurs.
class MerchantShell extends StatefulWidget {
  const MerchantShell({super.key});

  @override
  State<MerchantShell> createState() => _MerchantShellState();
}

class _MerchantShellState extends State<MerchantShell> {
  int _index = 0;

  static const List<_MerchantTab> _tabs = [
    _MerchantTab('Tableau de bord', Icons.insights_outlined, Icons.insights),
    _MerchantTab('Mes offres', Icons.sell_outlined, Icons.sell),
    _MerchantTab('Reçu', Icons.inbox_outlined, Icons.inbox),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantReady) {
          return _buildShell(context, state);
        }
        if (state is MerchantUnknown || state is MerchantLoading) {
          // On ne sait pas encore : on montre la forme de l'espace plutôt
          // qu'un spinner, pour que l'écran ne change pas de nature quand
          // les chiffres arrivent.
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: const CustomAppBar(
              automaticallyImplyLeading: false,
              widget: Skeletonizer(
                enabled: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Bone.text(width: 140),
                    SizedBox(height: 4),
                    Bone.text(width: 90),
                  ],
                ),
              ),
            ),
            body: const MerchantSpaceSkeleton(),
          );
        }

        // Plus commerçant (déconnexion, ou espace injoignable) : l'écran
        // n'a plus rien à montrer, on rend la main à l'application cliente.
        return Scaffold(
          body: MerchantEmptyState(
            icon: Icons.storefront_outlined,
            title: 'Espace commerçant indisponible',
            message:
                'Reconnectez-vous pour retrouver la gestion de votre '
                'commerce.',
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.appPaddingValue),
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Retour à l\'application'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShell(BuildContext context, MerchantReady state) {
    final pendingCount =
        state.space.stats.pendingOrders + state.space.stats.pendingReservations;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.space.business?.name ?? 'Mon commerce',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Espace commerçant',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Parcourir Baobabe',
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.storefront_outlined),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          MerchantDashboardScreen(
            space: state.space,
            onSeeOffers: () => setState(() => _index = 1),
            onSeeInbox: () => setState(() => _index = 2),
          ),
          MerchantOffersScreen(space: state.space),
          MerchantInboxScreen(space: state.space),
        ],
      ),
      bottomNavigationBar: _NavBar(
        tabs: _tabs,
        currentIndex: _index,
        badgeOnIndex: pendingCount > 0 ? 2 : null,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _MerchantTab {
  final String label;
  final IconData outlined;
  final IconData filled;

  const _MerchantTab(this.label, this.outlined, this.filled);
}

/// Reprend la forme de la barre du client — pastille verte pleine sur
/// l'onglet actif — pour que l'application reste la même application.
class _NavBar extends StatelessWidget {
  final List<_MerchantTab> tabs;
  final int currentIndex;
  final int? badgeOnIndex;
  final ValueChanged<int> onTap;

  const _NavBar({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.badgeOnIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isSelected = index == currentIndex;
              final showBadge = badgeOnIndex == index && !isSelected;

              return Semantics(
                label: tab.label,
                button: true,
                selected: isSelected,
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: isSelected
                        ? BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radius50,
                            ),
                          )
                        : null,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 18 : 12,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Badge(
                          isLabelVisible: showBadge,
                          child: Icon(
                            isSelected ? tab.filled : tab.outlined,
                            size: 20,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (isSelected) ...[
                          AppDimens.spacerSmallWidth,
                          Text(
                            tab.label,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
