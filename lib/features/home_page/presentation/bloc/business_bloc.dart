import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_home_feed.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'business_event.dart';
part 'business_state.dart';

/// Pilote toute la page d'accueil. Le filtrage par catégorie est fait côté
/// serveur (`get-home`) : changer de catégorie recharge les trois sections
/// d'un coup, plutôt que de laisser chaque widget re-filtrer une liste
/// commune dans son coin.
class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final GetHomeFeed getHomeFeed;
  final GetBusinessesPage getBusinessesPage;

  /// Jeton de la dernière demande de page d'accueil. Un tap rapide sur
  /// plusieurs catégories lance plusieurs requêtes concurrentes : seule la
  /// plus récente a le droit d'émettre, sinon une réponse lente pourrait
  /// écraser l'affichage d'une catégorie sélectionnée après elle.
  int _homeRequestId = 0;

  BusinessBloc({required this.getHomeFeed, required this.getBusinessesPage})
    : super(BusinessInitial()) {
    on<LoadBusinesses>(_onLoadBusinesses);
    on<LoadBusinessesByCategory>(_onLoadBusinessesByCategory);
    on<LoadMoreBusinesses>(_onLoadMoreBusinesses);
  }

  /// Paramètre `category` envoyé au serveur. "Tout" est représenté côté
  /// client par [BusinessType.all] ou [BusinessType.other] : dans les deux
  /// cas, aucun filtre.
  String? _categoryParam(BusinessType category) =>
      (category == BusinessType.all || category == BusinessType.other)
      ? null
      : category.name;

  Future<void> _onLoadBusinesses(
    LoadBusinesses event,
    Emitter<BusinessState> emit,
  ) => _loadHome(BusinessType.all, emit);

  Future<void> _onLoadBusinessesByCategory(
    LoadBusinessesByCategory event,
    Emitter<BusinessState> emit,
  ) => _loadHome(event.category, emit);

  Future<void> _loadHome(
    BusinessType category,
    Emitter<BusinessState> emit,
  ) async {
    final requestId = ++_homeRequestId;
    emit(BusinessLoading());

    try {
      final feed = await getHomeFeed(
        GetHomeFeedParams(category: _categoryParam(category)),
      );
      if (requestId != _homeRequestId) return;

      emit(
        BusinessLoaded(
          businesses: feed.discover.items,
          currentCategory: category,
          newBusinesses: feed.newBusinesses,
          popularBusinesses: feed.popularBusinesses,
          page: 1,
          hasMore: feed.discover.hasMore,
        ),
      );
    } catch (e) {
      if (requestId != _homeRequestId) return;
      emit(BusinessError("Erreur lors du chargement : ${e.toString()}"));
    }
  }

  Future<void> _onLoadMoreBusinesses(
    LoadMoreBusinesses event,
    Emitter<BusinessState> emit,
  ) async {
    final current = state;
    // Rien à faire : pas encore chargé, plus rien à charger, ou un
    // chargement est déjà en cours (évite les doublons quand l'UI
    // redéclenche l'événement plusieurs fois pendant le scroll).
    if (current is! BusinessLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    final requestId = _homeRequestId;
    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.page + 1;

    try {
      // Seule la section "Découvrir" est paginée : "Nouveautés" et
      // "Populaires" ne bougent pas et ne sont donc pas redemandées.
      final page = await getBusinessesPage(
        GetBusinessesPageParams(
          page: nextPage,
          category: _categoryParam(current.currentCategory),
        ),
      );
      // Un changement de catégorie a eu lieu entre-temps : cette page
      // appartient à l'ancienne liste, on la jette.
      if (requestId != _homeRequestId) return;

      emit(
        current.copyWith(
          businesses: [...current.businesses, ...page.items],
          page: nextPage,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (requestId != _homeRequestId) return;
      // Échec silencieux : l'utilisateur redevient libre de scroller pour
      // réessayer, plutôt que de rester bloqué sur isLoadingMore=true.
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
