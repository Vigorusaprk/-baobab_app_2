import 'dart:async';
import 'package:baobabe_0_2/features/home_page/presentation/screens/notifications_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baobabe_0_2/core/services/session_service.dart';

// Écrans de la Feature Auth
import 'package:baobabe_0_2/features/auth/presentation/screens/auth_screen.dart';

// Autres Écrans de l'application
import 'package:baobabe_0_2/app/main_shell.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/home_page_screen.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/search_page.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/all_businesses_screen.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/screens/boking_detail_screen.dart';
import 'package:baobabe_0_2/features/activity/presentation/screens/activity_screen.dart';
import 'package:baobabe_0_2/features/order/presentation/screens/order_detail_page.dart';
import 'package:baobabe_0_2/features/settings/presentation/screens/settings_screen.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/screens/business_detail_screen.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/screens/offer_detail_screen.dart';
import 'package:baobabe_0_2/features/merchant/presentation/screens/become_merchant_page.dart';
import 'package:baobabe_0_2/features/merchant/presentation/screens/merchant_shell.dart';
import 'package:baobabe_0_2/features/merchant/presentation/screens/offer_form_page.dart';

// Modèles/Entités
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
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
final List<ValueNotifier<int>> branchStackDepth = List.generate(
  4,
  (_) => ValueNotifier(0),
);

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
  // NOTE: no refreshListenable here on purpose. Closing the auth screen is
  // handled explicitly (see AuthForm / LoginPage BlocListeners) so the user
  // returns to the exact page they were on. Wiring Supabase's auth stream
  // into refreshListenable would fire this `redirect` reactively and force
  // a full-stack replace to '/home' the instant the session updates, racing
  // with those explicit pops (and clobbering the previous page in history).
  redirect: (context, state) {
    final isLoggedIn = SessionService.instance.isLoggedIn;
    final isAuthRoute =
        state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/register') ||
        state.matchedLocation.startsWith('/forgot-password');

    if (isLoggedIn && isAuthRoute) return '/home';

    return null;
  },
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/home'),

    // --- ROUTES D'AUTHENTIFICATION ---
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
    ),

    // --- SHELL DE NAVIGATION PRINCIPAL (avec bottom bar) ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(
          navigationShell: navigationShell,
          branchStackDepth: branchStackDepth,
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
              path: '/expolre',
              name: 'expolre',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SearchPageBody()),
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
                  const NoTransitionPage(child: ActivityScreen()),
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
    // Une offre est une destination à part entière : on y arrive depuis
    // l'accueil, la recherche ou le catalogue d'un commerçant, et c'est là
    // qu'on commande ou qu'on réserve.
    GoRoute(
      path: '/offer/:id',
      name: 'offerDetail',
      pageBuilder: (context, state) => MaterialPage(
        child: OfferDetailScreen(offerId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/businesses',
      name: 'allBusinesses',
      pageBuilder: (context, state) {
        // Destination du "Voir tout" de l'accueil : la categorie affichee
        // et son libelle sont passes tels quels pour que la liste complete
        // corresponde exactement a ce que l'utilisateur voyait.
        final extra = state.extra as Map<String, dynamic>?;
        return MaterialPage(
          child: AllBusinessesScreen(
            categorySlug: extra?['categorySlug'] as String?,
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
            child: Scaffold(
              body: Center(child: Text('Réservation introuvable')),
            ),
          );
        }
        return MaterialPage(
          child: ReservationDetailPage(reservation: reservation),
        );
      },
    ),
    // --- ESPACE COMMERÇANT ---
    //
    // Hors du shell client : un commerçant ne navigue plus dans un
    // catalogue, il gère un commerce. MerchantShell apporte sa propre
    // coquille et sa propre barre de navigation.
    GoRoute(
      path: '/merchant',
      name: 'merchant',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: MerchantShell()),
      routes: [
        GoRoute(
          path: 'offer',
          name: 'offerForm',
          pageBuilder: (context, state) =>
              MaterialPage(child: OfferFormPage(offer: state.extra as Offer?)),
        ),
      ],
    ),
    GoRoute(
      path: '/become-merchant',
      name: 'becomeMerchant',
      pageBuilder: (context, state) =>
          const MaterialPage(child: BecomeMerchantPage()),
    ),
  ],
);
