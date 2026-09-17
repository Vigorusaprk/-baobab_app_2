import 'dart:async';

import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/data/explore_api_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/offer_search_filters.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum OffersSearchStatus { initial, loading, ready, failure }

/// L'état de « Toutes les offres » : un jeu de critères, et ce que le
/// serveur a répondu.
class OffersSearchState extends Equatable {
  const OffersSearchState({
    this.filters = const OfferSearchFilters(),
    this.offers = const [],
    this.status = OffersSearchStatus.initial,
    this.hasMore = false,
    this.loadingMore = false,
    this.message,
    this.page = 1,
  });

  final OfferSearchFilters filters;
  final List<Offer> offers;
  final OffersSearchStatus status;
  final bool hasMore;
  final bool loadingMore;

  /// Message écrit à montrer en cas d'échec. Jamais une exception.
  final String? message;

  /// La dernière page reçue du serveur.
  ///
  /// Suivie explicitement plutôt que déduite du nombre d'offres : une page
  /// n'est pleine que si le serveur avait de quoi la remplir, et la division
  /// redemandait alors la page déjà lue.
  final int page;

  OffersSearchState copyWith({
    OfferSearchFilters? filters,
    List<Offer>? offers,
    OffersSearchStatus? status,
    bool? hasMore,
    bool? loadingMore,
    String? message,
    int? page,
    bool clearMessage = false,
  }) => OffersSearchState(
    filters: filters ?? this.filters,
    offers: offers ?? this.offers,
    status: status ?? this.status,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    message: clearMessage ? null : (message ?? this.message),
    page: page ?? this.page,
  );

  @override
  List<Object?> get props => [
    filters,
    offers,
    status,
    hasMore,
    loadingMore,
    message,
    page,
  ];
}

/// « Toutes les offres » : la recherche d'offres, avec ses filtres — prix,
/// mode de retrait, note, tri.
///
/// C'était Explorer, avant qu'Explorer ne montre que des commerces. La page
/// vit derrière « Offres du moment · Voir tout » et a son propre cubit :
/// ce qu'on y tape ne doit pas resurgir dans l'onglet Explorer.
///
/// Toute modification des critères relance une requête. Une **temporisation**
/// sépare la frappe de l'appel : sans elle, « restaurant » partirait dix fois
/// au serveur, et les réponses pourraient revenir dans le désordre.
class OffersSearchCubit extends Cubit<OffersSearchState> {
  OffersSearchCubit({ExploreApiService? api, String? categorySlug})
    : _api = api ?? ExploreApiService(),
      super(
        OffersSearchState(
          filters: OfferSearchFilters(
            categorySlug: categorySlug == null || categorySlug == 'all'
                ? null
                : categorySlug,
          ),
        ),
      );

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
    if (state.status != OffersSearchStatus.initial) return Future.value();
    return _run(state.filters);
  }

  /// La frappe au clavier : on attend une pause avant d'interroger.
  void queryChanged(String query) {
    final filters = state.filters.copyWith(query: query);
    emit(state.copyWith(filters: filters));
    _debounce?.cancel();
    _debounce = Timer(_typingPause, () => _run(filters));
  }

  /// Un critère posé d'un geste — catégorie, panneau de filtres, tri : pas de
  /// temporisation, l'intention est déjà complète.
  Future<void> filtersChanged(OfferSearchFilters filters) {
    _debounce?.cancel();
    emit(state.copyWith(filters: filters));
    return _run(filters);
  }

  Future<void> categorySelected(String? slug) {
    final filters = slug == null || slug == 'all'
        ? state.filters.copyWith(clearCategory: true)
        : state.filters.copyWith(categorySlug: slug);
    return filtersChanged(filters);
  }

  Future<void> clearFacets() => filtersChanged(state.filters.clearedFacets());

  Future<void> retry() => _run(state.filters);

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore) return;
    if (state.status != OffersSearchStatus.ready) return;

    emit(state.copyWith(loadingMore: true));
    final nextPage = state.page + 1;
    try {
      final result = await _api.search(state.filters, page: nextPage);
      if (isClosed) return;
      emit(
        state.copyWith(
          offers: [...state.offers, ...result.items],
          hasMore: result.hasMore,
          loadingMore: false,
          page: nextPage,
        ),
      );
    } catch (e) {
      debugPrint('Toutes les offres — page suivante, échec : $e');
      if (isClosed) return;
      // Une page suivante qui échoue ne doit pas effacer ce qui est déjà là.
      emit(state.copyWith(loadingMore: false, hasMore: false));
    }
  }

  Future<void> _run(OfferSearchFilters filters) async {
    final id = ++_requestId;
    emit(
      state.copyWith(status: OffersSearchStatus.loading, clearMessage: true),
    );

    try {
      final result = await _api.search(filters);
      if (id != _requestId || isClosed) return;
      emit(
        state.copyWith(
          offers: result.items,
          hasMore: result.hasMore,
          status: OffersSearchStatus.ready,
          loadingMore: false,
          page: 1,
        ),
      );
    } catch (e) {
      debugPrint('Toutes les offres — recherche, échec : $e');
      if (id != _requestId || isClosed) return;
      emit(
        state.copyWith(
          status: OffersSearchStatus.failure,
          message:
              "Les offres n'ont pas pu être chargées. Vérifiez votre "
              'connexion et réessayez.',
        ),
      );
    }
  }
}
