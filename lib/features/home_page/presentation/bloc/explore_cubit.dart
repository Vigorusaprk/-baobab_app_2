import 'dart:async';

import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/data/explore_api_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/offer_search_filters.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// L'état d'Explorer : un jeu de critères, et ce que le serveur a répondu.
class ExploreState extends Equatable {
  const ExploreState({
    this.filters = const OfferSearchFilters(),
    this.offers = const [],
    this.status = ExploreStatus.initial,
    this.hasMore = false,
    this.loadingMore = false,
    this.message,
    this.page = 1,
    this.pendingIntent,
  });

  final OfferSearchFilters filters;
  final List<Offer> offers;
  final ExploreStatus status;
  final bool hasMore;
  final bool loadingMore;

  /// Message écrit à montrer en cas d'échec. Jamais une exception.
  final String? message;

  /// Ce que l'écran doit faire dès son affichage, à la demande de l'accueil.
  ///
  /// Consommé par l'écran puis remis à `null`. Le passer par la route aurait
  /// mis un paramètre dans l'URL, qui serait resté après coup et aurait rejoué
  /// l'action à chaque retour sur l'onglet.
  final ExploreIntent? pendingIntent;

  /// La dernière page reçue du serveur.
  ///
  /// Suivie explicitement plutôt que déduite du nombre d'offres : une page
  /// n'est pleine que si le serveur avait de quoi la remplir, et la division
  /// redemandait alors la page déjà lue.
  final int page;

  ExploreState copyWith({
    OfferSearchFilters? filters,
    List<Offer>? offers,
    ExploreStatus? status,
    bool? hasMore,
    bool? loadingMore,
    String? message,
    int? page,
    ExploreIntent? pendingIntent,
    bool clearMessage = false,
    bool clearIntent = false,
  }) => ExploreState(
    filters: filters ?? this.filters,
    offers: offers ?? this.offers,
    status: status ?? this.status,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    message: clearMessage ? null : (message ?? this.message),
    page: page ?? this.page,
    pendingIntent: clearIntent ? null : (pendingIntent ?? this.pendingIntent),
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
    pendingIntent,
  ];
}

enum ExploreStatus { initial, loading, ready, failure }

/// Ce que l'écran d'où l'on vient demande à Explorer de faire en arrivant.
///
/// Une seule valeur à la fois, et non deux drapeaux : la barre de recherche et
/// le bouton de filtre de l'accueil s'excluent, et deux booléens auraient
/// laissé exister un état que personne ne peut produire.
enum ExploreIntent {
  /// Ouvrir le panneau de filtres — le bouton de l'accueil.
  openFilters,

  /// Donner le focus au champ : l'utilisateur a touché la barre de recherche
  /// de l'accueil, il veut taper. Sans cela il devait toucher une seconde
  /// fois, une fois arrivé.
  focusSearch,
}

/// Explorer : la recherche d'offres.
///
/// Toute modification des critères relance une requête. Une **temporisation**
/// sépare la frappe de l'appel : sans elle, « restaurant » partirait dix fois
/// au serveur, et les réponses pourraient revenir dans le désordre.
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

  /// Demande à Explorer d'ouvrir son panneau de filtres dès son affichage.
  void requestFilters() =>
      emit(state.copyWith(pendingIntent: ExploreIntent.openFilters));

  /// Demande à Explorer de donner le focus au champ de recherche.
  void requestSearch() =>
      emit(state.copyWith(pendingIntent: ExploreIntent.focusSearch));

  /// L'écran a fait ce qu'on lui demandait : la demande est consommée.
  void intentHandled() => emit(state.copyWith(clearIntent: true));

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore) return;
    if (state.status != ExploreStatus.ready) return;

    emit(state.copyWith(loadingMore: true));
    final nextPage = state.page + 1;
    try {
      final result = await _api.search(state.filters, page: nextPage);
      emit(
        state.copyWith(
          offers: [...state.offers, ...result.items],
          hasMore: result.hasMore,
          loadingMore: false,
          page: nextPage,
        ),
      );
    } catch (e) {
      debugPrint('Explorer — page suivante, échec : $e');
      // Une page suivante qui échoue ne doit pas effacer ce qui est déjà là.
      emit(state.copyWith(loadingMore: false, hasMore: false));
    }
  }

  Future<void> _run(OfferSearchFilters filters) async {
    final id = ++_requestId;
    emit(state.copyWith(status: ExploreStatus.loading, clearMessage: true));

    try {
      final result = await _api.search(filters);
      if (id != _requestId || isClosed) return;
      emit(
        state.copyWith(
          offers: result.items,
          hasMore: result.hasMore,
          status: ExploreStatus.ready,
          loadingMore: false,
          page: 1,
        ),
      );
    } catch (e) {
      debugPrint('Explorer — recherche, échec : $e');
      if (id != _requestId || isClosed) return;
      emit(
        state.copyWith(
          status: ExploreStatus.failure,
          message:
              "Les offres n'ont pas pu être chargées. Vérifiez votre "
              'connexion et réessayez.',
        ),
      );
    }
  }
}
