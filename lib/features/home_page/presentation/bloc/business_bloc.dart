import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'business_event.dart';
part 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final GetBusinessesPage getBusinessesPage;

  /// Cache local du flux "tous les business" non filtré — sert à revenir
  /// instantanément dessus quand l'utilisateur repasse à la catégorie
  /// "all", sans refaire d'appel réseau. Sa propre pagination est suivie
  /// séparément de celle d'un flux filtré par catégorie.
  List<Business> _allBusinesses = [];
  int _allBusinessesPage = 1;
  bool _allBusinessesHasMore = false;

  BusinessBloc({required this.getBusinessesPage}) : super(BusinessInitial()) {
    on<LoadBusinesses>(_onLoadBusinesses);
    on<LoadBusinessesByCategory>(_onLoadBusinessesByCategory);
    on<LoadMoreBusinesses>(_onLoadMoreBusinesses);
  }

  Future<void> _onLoadBusinesses(
    LoadBusinesses event,
    Emitter<BusinessState> emit,
  ) async {
    emit(BusinessLoading());
    try {
      final page = await getBusinessesPage(
        const GetBusinessesPageParams(page: 1),
      );
      _allBusinesses = page.items;
      _allBusinessesPage = 1;
      _allBusinessesHasMore = page.hasMore;
      emit(
        BusinessLoaded(
          businesses: page.items,
          currentCategory: BusinessType.all,
          allBusinesses: page.items,
          page: 1,
          hasMore: page.hasMore,
        ),
      );
    } catch (e) {
      emit(BusinessError("Erreur lors du chargement : ${e.toString()}"));
    }
  }

  void _onLoadBusinessesByCategory(
    LoadBusinessesByCategory event,
    Emitter<BusinessState> emit,
  ) {
    // Si la catégorie est 'all' ou 'other', on réaffiche le cache local
    // avec sa propre pagination — pas besoin de refaire une requête.
    if (event.category == BusinessType.all ||
        event.category == BusinessType.other) {
      emit(
        BusinessLoaded(
          businesses: List.from(_allBusinesses),
          currentCategory: event.category,
          allBusinesses: List.from(_allBusinesses),
          page: _allBusinessesPage,
          hasMore: _allBusinessesHasMore,
        ),
      );
      return;
    }

    // Filtrage synchrone dans ce qui est déjà en cache. `hasMore` reste à
    // true : le serveur peut avoir davantage de résultats de cette
    // catégorie que ce qui est actuellement chargé localement —
    // LoadMoreBusinesses ira les chercher directement filtrés côté serveur.
    final filtered = _allBusinesses.where((business) {
      return business.type.name.toLowerCase() ==
          event.category.name.toLowerCase();
    }).toList();

    emit(
      BusinessLoaded(
        businesses: filtered,
        currentCategory: event.category,
        allBusinesses: List.from(_allBusinesses),
        page: 1,
        hasMore: true,
      ),
    );
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

    emit(current.copyWith(isLoadingMore: true));

    final isFiltered =
        current.currentCategory != BusinessType.all &&
        current.currentCategory != BusinessType.other;
    final nextPage = current.page + 1;

    try {
      final page = await getBusinessesPage(
        GetBusinessesPageParams(
          page: nextPage,
          category: isFiltered ? current.currentCategory.name : null,
        ),
      );

      if (!isFiltered) {
        _allBusinesses = [..._allBusinesses, ...page.items];
        _allBusinessesPage = nextPage;
        _allBusinessesHasMore = page.hasMore;
      }

      emit(
        current.copyWith(
          businesses: [...current.businesses, ...page.items],
          allBusinesses: List.from(_allBusinesses),
          page: nextPage,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // Échec silencieux : l'utilisateur redevient libre de scroller pour
      // réessayer, plutôt que de rester bloqué sur isLoadingMore=true.
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
