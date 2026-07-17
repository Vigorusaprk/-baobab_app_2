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

/// Routes that require an authenticated account, e.g. because they show or
/// edit user-specific data (own reservations, own orders, profile/settings).
/// Plain browsing (home, search, business detail) never requires login —
/// account creation is only prompted when the user attempts an action that
/// needs one.
const _authRequiredPaths = ['/favorites', '/orders', '/settings', '/profil-page', '/edit-profile'];

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(SessionService.instance.authStateChanges),
  redirect: (context, state) {
    final isLoggedIn = SessionService.instance.isLoggedIn;
    final isAuthRoute =
        state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/register') ||
        state.matchedLocation.startsWith('/forgot-password');
    final requiresAuth = _authRequiredPaths.any((path) => state.matchedLocation.startsWith(path));

    // 🔒 Redirection uniquement pour les pages qui nécessitent réellement un compte
    if (!isLoggedIn && requiresAuth) return '/login';

    // 🔓 Redirection si l'utilisateur est connecté et accède à une page d'authentification
    if (isLoggedIn && isAuthRoute) return '/home';

    return null;
  },
  routes: [
    // Route racine : navigation libre, sans compte requis
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
      pageBuilder: (context, state) => const MaterialPage(
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    ),

    // --- ROUTES D'AUTHENTIFICATION ---
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
    ),

    // --- SHELL DE NAVIGATION PRINCIPAL ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
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
        final order = state.extra as Order;
        return MaterialPage(child: OrderDetailPage(order: order));
      },
    ),
    GoRoute(
      path: '/reservation-detail',
      name: 'reservationDetail',
      pageBuilder: (context, state) {
        final reservation = state.extra as Reservation;
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
