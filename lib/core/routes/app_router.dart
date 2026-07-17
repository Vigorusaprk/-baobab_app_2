import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Injection & Blocs
import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';

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

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(Injector.get<AuthBloc>().stream),
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;

    // Pendant l'initialisation ou les chargements internes, on ne force pas de redirection immédiate
    if (authState is AuthInitialState || authState is AuthLoadingState)
      return null;

    final isLoggedIn = authState is AuthenticatedState;
    final isAuthRoute =
        state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/register') ||
        state.matchedLocation.startsWith('/forgot-password');

    // 🔒 Redirection si l'utilisateur n'est pas connecté et accède à une page privée
    if (!isLoggedIn && !isAuthRoute) return '/login';

    // 🔓 Redirection si l'utilisateur est connecté et accède à une page d'authentification
    if (isLoggedIn && isAuthRoute) return '/home';

    return null;
  },
  routes: [
    // Route racine adaptative
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;

        if (authState is AuthenticatedState) return '/home';
        if (authState is UnauthenticatedState || authState is AuthFailureState)
          return '/login';

        // En cas d'état initial non déterminé, on temporise sur le login
        if (authState is AuthInitialState) return '/login';

        return null;
      },
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
