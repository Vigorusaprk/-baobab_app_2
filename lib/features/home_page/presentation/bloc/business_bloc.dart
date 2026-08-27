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
    on<LoadBusinessesBySlug>(_onLoadBusinessesBySlug);
    on<LoadMoreBusinesses>(_onLoadMoreBusinesses);
  }

  /// Slug de la catégorie "aucun filtre", ajoutée côté client.
  static const String allSlug = 'all';

  /// Paramètre `category` envoyé au serveur : rien à filtrer pour "Tout".
  static String? _categoryParam(String slug) =>
      (slug.isEmpty || slug == allSlug || slug == 'other') ? null : slug;

  Future<void> _onLoadBusinesses(
    LoadBusinesses event,
    Emitter<BusinessState> emit,
  ) => _loadHome(allSlug, emit);

  Future<void> _onLoadBusinessesBySlug(
    LoadBusinessesBySlug event,
    Emitter<BusinessState> emit,
  ) => _loadHome(event.slug, emit);

  Future<void> _loadHome(String slug, Emitter<BusinessState> emit) async {
    final requestId = ++_homeRequestId;
    emit(BusinessLoading());

    try {
      final feed = await getHomeFeed(
        GetHomeFeedParams(category: _categoryParam(slug)),
      );
      if (requestId != _homeRequestId) return;

      emit(
        BusinessLoaded(
          businesses: feed.discover.items,
          currentSlug: slug,
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
          category: _categoryParam(current.currentSlug),
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
