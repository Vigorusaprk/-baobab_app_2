import 'dart:async';

import 'package:baobabe_0_2/features/home_page/data/explore_api_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_search_filters.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'explore_state.dart';

/// Explorer : l'annuaire des **commerces**. Rien d'autre.
///
/// C'est ce que la plateforme met en avant, et c'est tout ce que l'onglet
/// montre. Les offres ont leur propre page, « Toutes les offres », derrière
/// l'accueil — voir `OffersSearchCubit`. Un sélecteur qui faisait cohabiter
/// les deux ici brouillait la question posée à l'écran.
///
/// Toute modification des critères relance une requête. Une
/// **temporisation** sépare la frappe de l'appel : sans elle, « restaurant »
/// partirait dix fois au serveur, et les réponses pourraient revenir dans le
/// désordre.
class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit({ExploreApiService? api})
    : _api = api ?? ExploreApiService(),
      super(const ExploreState());

  final ExploreApiService _api;
  Timer? _debounce;

  /// Numéro de la dernière requête lancée. Une réponse plus ancienne qui
  /// arrive après une plus récente est ignorée : sans ce garde, une requête
  /// lente écraserait le résultat de la recherche suivante.
  int _requestId = 0;

  static const Duration _typingPause = Duration(milliseconds: 350);

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> start() {
    if (state.status != ExploreStatus.initial) return Future.value();
    return _run();
  }

  // --- Les critères ----------------------------------------------------

  /// La frappe au clavier : on attend une pause avant d'interroger.
  void queryChanged(String query) {
    emit(state.copyWith(filters: state.filters.copyWith(query: query)));
    _debounce?.cancel();
    _debounce = Timer(_typingPause, _run);
  }

  Future<void> categorySelected(String? slug) {
    final clear = slug == null || slug == 'all';
    _debounce?.cancel();
    emit(
      state.copyWith(
        filters: clear
            ? state.filters.copyWith(clearCategory: true)
            : state.filters.copyWith(categorySlug: slug),
      ),
    );
    return _run();
  }

  /// Un critère posé d'un geste — la feuille de filtres : pas de
  /// temporisation, l'intention est déjà complète.
  Future<void> filtersChanged(BusinessSearchFilters filters) {
    _debounce?.cancel();
    emit(state.copyWith(filters: filters));
    return _run();
  }

  Future<void> clearFacets() => filtersChanged(state.filters.clearedFacets());

  Future<void> retry() => _run();

  // --- Les intentions de l'accueil --------------------------------------

  /// Demande à Explorer d'ouvrir sa feuille de filtres dès son affichage.
  void requestFilters() =>
      emit(state.copyWith(pendingIntent: ExploreIntent.openFilters));

  /// Demande à Explorer de donner le focus au champ de recherche.
  void requestSearch() =>
      emit(state.copyWith(pendingIntent: ExploreIntent.focusSearch));

  /// L'écran a fait ce qu'on lui demandait : la demande est consommée.
  void intentHandled() => emit(state.copyWith(clearIntent: true));

  // --- Les pages -------------------------------------------------------

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore) return;
    if (state.status != ExploreStatus.ready) return;

    emit(state.copyWith(loadingMore: true));
    final nextPage = state.page + 1;
    try {
      final result = await _api.searchBusinesses(state.filters, page: nextPage);
      if (isClosed) return;
      emit(
        state.copyWith(
          businesses: [...state.businesses, ...result.items],
          hasMore: result.hasMore,
          page: nextPage,
          loadingMore: false,
        ),
      );
    } catch (e) {
      debugPrint('Explorer — page suivante, échec : $e');
      if (isClosed) return;
      // Une page suivante qui échoue ne doit pas effacer ce qui est déjà là.
      emit(state.copyWith(loadingMore: false, hasMore: false));
    }
  }

  Future<void> _run() async {
    final id = ++_requestId;
    emit(state.copyWith(status: ExploreStatus.loading, clearMessage: true));

    try {
      final result = await _api.searchBusinesses(state.filters);
      if (id != _requestId || isClosed) return;
      emit(
        state.copyWith(
          businesses: result.items,
          hasMore: result.hasMore,
          page: 1,
          status: ExploreStatus.ready,
          loadingMore: false,
        ),
      );
    } catch (e) {
      debugPrint('Explorer — recherche, échec : $e');
      if (id != _requestId || isClosed) return;
      emit(
        state.copyWith(
          status: ExploreStatus.failure,
          message:
              "Les commerces n'ont pas pu être chargés. Vérifiez votre "
              'connexion et réessayez.',
        ),
      );
    }
  }
}
