import 'package:baobabe_0_2/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/plat_detail.dart';
import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_model.dart';
// Supprimer l'import de reservation_service.dart
// import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/reservation_service.dart';
import 'package:baobabe_0_2/features/favorites_page/presentation/screens/boking_detail_screen.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/search_page.dart';
import 'package:baobabe_0_2/features/main/presentation/screens/main_screen.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/screens/order_detail_page.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profil_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/screens/auth_screen.dart';
import 'package:baobabe_0_2/features/auth/presentation/screens/sign_up_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/screens/business_detail_screen.dart';
import 'package:baobabe_0_2/features/favorites_page/presentation/screens/favorites_page_screen.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/home_page_screen.dart';
import 'package:baobabe_0_2/features/order/presentation/screens/order_screen.dart';
import 'package:baobabe_0_2/features/settings/presentation/screens/settings_screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/register') ||
        state.matchedLocation.startsWith('/forgot-password');

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }
    return null;
  },
  routes: [
    // Routes publiques
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => const MaterialPage(child: SignUpPage()),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      pageBuilder: (context, state) => const MaterialPage(child: ForgotPasswordScreen()),
    ),

    // Shell principal
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePageScreen()),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder: (context, state) => const NoTransitionPage(child: FavoritesPageScreen()),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/orders',
            name: 'orders',
            pageBuilder: (context, state) => const NoTransitionPage(child: OrderScreen()),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ]),
      ],
    ),

    // Autres routes protégées
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
        return MaterialPage(
          child: OrderDetailPage(order: order),
        );
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
      pageBuilder: (context, state) {
        return MaterialPage(
          child: ProfilPage(),
        );
      },
    ),
  ],
);