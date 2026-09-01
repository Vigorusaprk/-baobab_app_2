import 'dart:async';

import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// État de l'écran "Voir tout" : une seule liste paginée de commerces.
///
/// Volontairement distinct de `BusinessBloc`, qui pilote les trois sections
/// de l'accueil : ici on n'a besoin que de la liste, inutile de demander au
/// serveur "Nouveautés" et "Populaires" pour les jeter ensuite.
class BusinessListState extends Equatable {
  final List<Business> businesses;
  final bool isLoading;
  final String? errorMessage;

  /// Dernière page chargée (1 = premier chargement).
  final int page;

  /// S'il reste des pages à charger côté serveur.
  final bool hasMore;

  /// Vrai pendant qu'une page suivante se charge en arrière-plan.
  final bool isLoadingMore;

  /// Catégorie actuellement affichée (null = toutes). Portée par l'état
  /// pour que « charger plus » demande forcément la même que la liste déjà
  /// à l'écran.
  final String? category;

  /// Ce que l'utilisateur a tapé. Porté par l'état pour la même raison que la
  /// catégorie : la page suivante doit répondre à la **même** question que
  /// celle déjà affichée.
  final String query;

  const BusinessListState({
    this.businesses = const [],
    this.isLoading = true,
    this.errorMessage,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.category,
    this.query = '',
  });

  BusinessListState copyWith({
    List<Business>? businesses,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? category,
    String? query,
  }) {
    return BusinessListState(
      businesses: businesses ?? this.businesses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      category: category ?? this.category,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
    businesses,
    isLoading,
    errorMessage,
    page,
    hasMore,
    isLoadingMore,
    category,
    query,
  ];
}

/// Charge la liste complète des établissements d'une catégorie, page par
/// page. Toute la logique de pagination vit ici : la vue se contente de
/// signaler qu'elle approche de la fin de la liste.
class BusinessListCubit extends Cubit<BusinessListState> {
  final GetBusinessesPage getBusinessesPage;

  /// Jeton de la dernière demande. Changer rapidement de catégorie lance
  /// plusieurs requêtes concurrentes : seule la plus récente a le droit
  /// d'émettre, sinon une réponse lente écraserait la catégorie choisie
  /// après elle.
  int _requestId = 0;

  Timer? _debounce;

  /// La frappe attend une pause avant de partir au serveur. Sans elle,
  /// « restaurant » enverrait dix requêtes, et les réponses pourraient
  /// revenir dans le désordre.
  static const Duration _typingPause = Duration(milliseconds: 350);

  BusinessListCubit({required this.getBusinessesPage})
    : super(const BusinessListState());

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  /// (Re)charge la liste pour [category] (null = toutes catégories).
  ///
  /// La recherche en cours est conservée : changer de catégorie ne doit pas
  /// effacer ce que l'utilisateur a tapé.
  Future<void> load(String? category, {String? query}) async {
    final search = query ?? state.query;
    final requestId = ++_requestId;
    emit(BusinessListState(category: category, query: search));

    try {
      final result = await getBusinessesPage(
        GetBusinessesPageParams(page: 1, category: category, query: search),
      );
      if (requestId != _requestId) return;

      emit(
        BusinessListState(
          businesses: result.items,
          isLoading: false,
          page: 1,
          hasMore: result.hasMore,
          category: category,
          query: search,
        ),
      );
    } catch (e) {
      debugPrint('Liste des commerces — chargement, échec : $e');
      if (requestId != _requestId) return;
      emit(
        BusinessListState(
          isLoading: false,
          errorMessage:
              "La liste n'a pas pu être chargée. Vérifiez votre "
              'connexion et réessayez.',
          category: category,
          query: search,
        ),
      );
    }
  }

  /// L'utilisateur tape. On attend une pause avant d'interroger le serveur.
  void queryChanged(String query) {
    if (query == state.query) return;
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(_typingPause, () => load(state.category, query: query));
  }

  Future<void> loadMore() async {
    // Rien à faire : encore en chargement initial, plus rien à charger, ou
    // une page est déjà en route (la vue redéclenche pendant le scroll).
    if (state.isLoading || !state.hasMore || state.isLoadingMore) return;

    final requestId = _requestId;
    final current = state;
    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;

    try {
      final result = await getBusinessesPage(
        GetBusinessesPageParams(
          page: nextPage,
          category: current.category,
          query: current.query,
        ),
      );
      // Un changement de catégorie ou de recherche a eu lieu entre-temps :
      // cette page appartient à l'ancienne liste, on la jette.
      if (requestId != _requestId) return;

      emit(
        current.copyWith(
          businesses: [...current.businesses, ...result.items],
          page: nextPage,
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // Silencieux pour l'utilisateur, pas pour le journal : un `catch (_)`
      // muet a déjà caché une pagination cassée ailleurs dans ce projet.
      debugPrint('Liste des commerces — page suivante, échec : $e');
      if (requestId != _requestId) return;
      // L'utilisateur peut réessayer en continuant de scroller, plutôt que
      // de rester bloqué sur isLoadingMore.
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
