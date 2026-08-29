import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/feed_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository repository;

  FeedBloc({required this.repository}) : super(const FeedInitial()) {
    on<LoadFeedItems>(_onLoad);
    on<FeedFilterChanged>(_onFilterChanged);
    on<FeedItemTapped>(_onItemTapped);
  }

  Future<void> _onLoad(LoadFeedItems event, Emitter<FeedState> emit) async {
    emit(const FeedLoading());
    try {
      final items = await repository.getFeedItems();
      emit(FeedLoaded(allItems: items, activeFilter: FeedFilter.all));
    } catch (e) {
      debugPrint('Chargement de l\'accueil — échec : $e');
      emit(
        const FeedError(
          "L'accueil n'a pas pu être chargé. Vérifiez votre connexion "
          'et réessayez.',
        ),
      );
    }
  }

  void _onFilterChanged(FeedFilterChanged event, Emitter<FeedState> emit) {
    final current = state;
    if (current is FeedLoaded) {
      emit(current.copyWith(activeFilter: event.filter));
    }
  }

  Future<void> _onItemTapped(
    FeedItemTapped event,
    Emitter<FeedState> emit,
  ) async {
    final current = state;
    if (current is! FeedLoaded || event.item.isRead) return;

    await repository.markAsRead(event.item.id);
    final updated = current.allItems
        .map((i) => i.id == event.item.id ? i.copyWith(isRead: true) : i)
        .toList();
    emit(current.copyWith(allItems: updated));
  }
}
