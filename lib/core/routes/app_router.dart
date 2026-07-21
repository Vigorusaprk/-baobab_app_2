import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baobabe_0_2/core/services/session_service.dart';

// Écrans de la Feature Auth
import 'package:baobabe_0_2/features/auth/presentation/screens/auth_screen.dart';

// Autres Écrans de l'application
import 'package:baobabe_0_2/features/main/presentation/screens/main_screen.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/home_page_screen.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/search_page.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/screens/favorites_page_screen.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/screens/boking_detail_screen.dart';
import 'package:baobabe_0_2/features/order/presentation/screens/order_screen.dart';
import 'package:baobabe_0_2/features/order/presentation/screens/order_detail_page.dart';
import 'package:baobabe_0_2/features/settings/presentation/screens/settings_screen.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profil_page.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/edit_profile_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/screens/business_detail_screen.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/plat_detail.dart';

// Modèles/Entités
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';

/// Convertit le flux Stream du AuthBloc en un ChangeNotifier pour GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Nombre de pages empilées au-dessus de l'écran racine de chaque branche
/// du shell (0=home, 1=favorites, 2=orders, 3=settings).
final List<ValueNotifier<int>> branchStackDepth =
List.generate(4, (_) => ValueNotifier(0));

class _BranchDepthObserver extends NavigatorObserver {
  final ValueNotifier<int> depth;
  _BranchDepthObserver(this.depth);

  @override
  void didPush(Route route, Route? previousRoute) {
    if (previousRoute != null) depth.value++;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null && depth.value > 0) depth.value--;
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (previousRoute != null && depth.value > 0) depth.value--;
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final isLoggedIn = SessionService.instance.isLoggedIn;
    final isAuthRoute = state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/register') ||
        state.matchedLocation.startsWith('/forgot-password');

    // 🔓 Redirection si l'utilisateur est connecté et accède à une page d'authentification
    if (isLoggedIn && isAuthRoute) return '/home';

    return null;
  },
  routes: [
    // Route racine redirigeant proprement vers l'accueil public
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),

    // --- ROUTES D'AUTHENTIFICATION ---
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
    ),

    // --- SHELL DE NAVIGATION PRINCIPAL (avec bottom bar) ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(
          navigationShell: navigationShell,
          branchStackDepth: branchStackDepth,
          showBottomBar: state.matchedLocation == '/home' ||
              state.matchedLocation == '/favorites' ||
              state.matchedLocation == '/orders' ||
              state.matchedLocation == '/settings',
        );
      },
      branches: [
        StatefulShellBranch(
          observers: [_BranchDepthObserver(branchStackDepth[0])],
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePageScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          observers: [_BranchDepthObserver(branchStackDepth[1])],
          routes: [
            GoRoute(
              path: '/favorites',
              name: 'favorites',
              pageBuilder: (context, state) =>
              const NoTransitionPage(child: FavoritesPageScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          observers: [_BranchDepthObserver(branchStackDepth[2])],
          routes: [
            GoRoute(
              path: '/orders',
              name: 'orders',
              pageBuilder: (context, state) =>
              const NoTransitionPage(child: OrderScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          observers: [_BranchDepthObserver(branchStackDepth[3])],
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
            ),
          ],
        ),
      ],
    ),

    // --- ROUTES DE DÉTAILS ET PARAMÈTRES ---
    GoRoute(
      path: '/business/:id',
      name: 'businessDetail',
      pageBuilder: (context, state) {
        final businessId = state.pathParameters['id']!;
        return MaterialPage(
          child: BusinessDetailScreen(businessId: businessId),
        );
      },
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      pageBuilder: (context, state) => const MaterialPage(child: SearchPage()),
    ),
    GoRoute(
      path: '/plat',
      name: 'platDetail',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MaterialPage(
          child: PlatDetail(
            menuItem: extra?['menuItem'],
            restaurantId: extra?['restaurantId'],
            restaurantName: extra?['restaurantName'],
            restaurantType: extra?['restaurantType'],
          ),
        );
      },
    ),
    GoRoute(
      path: '/order-detail',
      name: 'orderDetail',
      pageBuilder: (context, state) {
        final order = state.extra as Order?;
        if (order == null) {
          return const MaterialPage(
            child: Scaffold(body: Center(child: Text('Commande introuvable'))),
          );
        }
        return MaterialPage(child: OrderDetailPage(order: order));
      },
    ),
    GoRoute(
      path: '/reservation-detail',
      name: 'reservationDetail',
      pageBuilder: (context, state) {
        final reservation = state.extra as Reservation?;
        if (reservation == null) {
          return const MaterialPage(
            child: Scaffold(body: Center(child: Text('Réservation introuvable'))),
          );
        }
        return MaterialPage(
          child: ReservationDetailPage(reservation: reservation),
        );
      },
    ),
    GoRoute(
      path: '/profil-page',
      name: 'profil-page',
      pageBuilder: (context, state) => const MaterialPage(child: ProfilPage()),
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      pageBuilder: (context, state) =>
      const MaterialPage(child: EditProfilePage()),
    ),
  ],
);