import 'dart:async';

import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/notification/data/notifications_api_service.dart';
import 'package:baobabe_0_2/features/notification/domain/entities/app_notification.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ce que l'écran des notifications montre.
///
/// Un seul état porteur plutôt qu'une famille de classes : la liste, le
/// filtre, la pastille et le chargement de la page suivante coexistent —
/// on charge la suite **sans** que la liste déjà affichée disparaisse.
class NotificationsState extends Equatable {
  const NotificationsState({
    this.items = const [],
    this.unread = 0,
    this.unreadOnly = false,
    this.page = 1,
    this.hasMore = false,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.isGuest = false,
    this.error,
  });

  final List<AppNotification> items;
  final int unread;
  final bool unreadOnly;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;

  /// Un visiteur sans compte n'a par définition aucune notification. L'écran
  /// le dit au lieu de montrer un vide qui ressemble à une panne.
  final bool isGuest;

  final String? error;

  NotificationsState copyWith({
    List<AppNotification>? items,
    int? unread,
    bool? unreadOnly,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isGuest,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      unread: unread ?? this.unread,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isGuest: isGuest ?? this.isGuest,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    items,
    unread,
    unreadOnly,
    page,
    hasMore,
    isLoading,
    isLoadingMore,
    isGuest,
    error,
  ];
}

/// Pilote le fil de notifications.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({NotificationsApiService? service})
    : _service = service ?? NotificationsApiService(),
      super(const NotificationsState()) {
    // Le cubit vit au niveau de l'application : la pastille de l'accueil et
    // l'écran du fil lisent le même compte, et deux instances finiraient
    // par se contredire. Il doit donc suivre la session lui-même — se
    // connecter remplit le fil, se déconnecter le vide.
    _authSubscription = SessionService.instance.authStateChanges.listen(
      (_) => load(),
    );
  }

  final NotificationsApiService _service;
  StreamSubscription<dynamic>? _authSubscription;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  /// Isolé pour que les tests répondent sans Supabase : la session n'existe
  /// pas hors de l'application, et un cubit qui se croit toujours visiteur
  /// n'est pas observable.
  @visibleForTesting
  bool get isSignedIn => SessionService.instance.isLoggedIn;

  Future<void> load() async {
    if (!isSignedIn) {
      emit(const NotificationsState(isLoading: false, isGuest: true));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final result = await _service.getPage(unreadOnly: state.unreadOnly);
      if (isClosed) return;
      emit(
        state.copyWith(
          items: result.items,
          unread: result.unread,
          hasMore: result.hasMore,
          page: 1,
          isLoading: false,
          isGuest: false,
          clearError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// La page suivante. La liste affichée ne bouge pas pendant l'attente.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = await _service.getPage(
        page: state.page + 1,
        unreadOnly: state.unreadOnly,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          items: [...state.items, ...next.items],
          unread: next.unread,
          page: state.page + 1,
          hasMore: next.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      // Une page suivante manquée laisse la liste telle quelle : elle est
      // seulement plus courte, ce qui vaut mieux qu'une erreur en travers
      // de ce qu'on lisait.
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  void toggleUnreadOnly(bool value) {
    if (value == state.unreadOnly) return;
    emit(state.copyWith(unreadOnly: value));
    load();
  }

  /// Marque une notification comme lue. L'état local bascule tout de suite —
  /// l'utilisateur vient de la toucher, il n'a pas à attendre le réseau pour
  /// la voir changer.
  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;

    final now = DateTime.now();
    emit(
      state.copyWith(
        items: state.items
            .map((i) => i.id == notification.id ? i.copyWith(readAt: now) : i)
            .toList(),
        unread: state.unread > 0 ? state.unread - 1 : 0,
      ),
    );

    try {
      final unread = await _service.markRead(id: notification.id);
      if (isClosed) return;
      emit(state.copyWith(unread: unread));
    } catch (_) {
      // Le serveur reste seul juge : on relit plutôt que de garder un état
      // local qu'il n'a pas accepté.
      if (!isClosed) await load();
    }
  }

  Future<void> markAllRead() async {
    if (state.unread == 0) return;

    final now = DateTime.now();
    emit(
      state.copyWith(
        items: state.items
            .map((i) => i.isRead ? i : i.copyWith(readAt: now))
            .toList(),
        unread: 0,
      ),
    );

    try {
      await _service.markRead(all: true);
      if (isClosed) return;
      // En mode « non lues », la liste vient de se vider : on relit pour
      // que l'écran dise ce qu'il en est plutôt que de garder des lignes
      // que le filtre exclut désormais.
      if (state.unreadOnly) await load();
    } catch (_) {
      if (!isClosed) await load();
    }
  }
}
