import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/discover_api_service.dart';
import 'discover_state.dart';

/// Charge et fait défiler le flux d'offres sans écrire sur le serveur.
class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit({DiscoverApiService? api})
    : _api = api ?? DiscoverApiService(), super(const DiscoverState());

  final DiscoverApiService _api;

  Future<void> start() => state.status == DiscoverStatus.initial
      ? _load(reset: true)
      : Future<void>.value();

  Future<void> categorySelected(String slug) {
    final clear = slug == 'all';
    emit(state.copyWith(
      status: DiscoverStatus.loading,
      items: const [],
      page: 1,
      hasMore: false,
      clearMessage: true,
      categorySlug: clear ? null : slug,
      clearCategory: clear,
      skippedIds: const {},
    ));
    return _load(reset: true);
  }

  void toggleSaved(String id) {
    final saved = {...state.savedIds};
    saved.contains(id) ? saved.remove(id) : saved.add(id);
    // TODO : connecter un stockage local si les favoris Découvrir deviennent persistants.
    emit(state.copyWith(savedIds: saved));
  }

  Future<void> skip(String id) async {
    emit(state.copyWith(skippedIds: {...state.skippedIds, id}));
    if (state.visibleItems.isEmpty && state.hasMore) await loadMore();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.status != DiscoverStatus.ready) return;
    emit(state.copyWith(loadingMore: true));
    await _load(reset: false);
  }

  Future<void> retry() => _load(reset: true);

  Future<void> _load({required bool reset}) async {
    final requestedPage = reset ? 1 : state.page + 1;
    try {
      final result = await _api.page(categorySlug: state.categorySlug, page: requestedPage);
      if (isClosed) return;
      emit(state.copyWith(
        status: DiscoverStatus.ready,
        items: reset ? result.items : [...state.items, ...result.items],
        page: requestedPage,
        hasMore: result.hasMore,
        loadingMore: false,
        clearMessage: true,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: reset ? DiscoverStatus.failure : DiscoverStatus.ready,
        loadingMore: false,
        message: "Les offres n'ont pas pu être chargées. Réessayez.",
      ));
    }
  }
}
