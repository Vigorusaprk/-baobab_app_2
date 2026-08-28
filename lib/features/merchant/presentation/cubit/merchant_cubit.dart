import 'dart:async';

import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MerchantState extends Equatable {
  const MerchantState();

  @override
  List<Object?> get props => [];
}

/// Avant toute réponse du serveur : on ne sait pas encore si l'utilisateur
/// est commerçant. Distinct de « il ne l'est pas » — basculer l'interface
/// sur cette seule ignorance ferait clignoter l'application au lancement.
class MerchantUnknown extends MerchantState {
  const MerchantUnknown();
}

class MerchantLoading extends MerchantState {
  const MerchantLoading();
}

/// L'utilisateur n'est pas commerçant. [application] porte l'état de sa
/// demande s'il en a déposé une.
class NotAMerchant extends MerchantState {
  final MerchantApplication? application;

  const NotAMerchant({this.application});

  @override
  List<Object?> get props => [application];
}

class MerchantReady extends MerchantState {
  final MerchantSpace space;

  /// Une action est en cours (changement de statut, publication d'offre).
  /// L'écran reste affiché : on ne renvoie pas le commerçant sur un
  /// squelette parce qu'il vient de confirmer une commande.
  final bool isWorking;

  const MerchantReady(this.space, {this.isWorking = false});

  @override
  List<Object?> get props => [space, isWorking];
}

/// Sait si l'utilisateur courant gère un commerce, et pilote son espace.
///
/// Vit au niveau de l'application : la réponse conditionne la navigation
/// (l'application s'ouvre sur l'espace commerçant) et l'affichage des
/// paramètres, deux endroits qui ne peuvent pas chacun refaire l'appel.
class MerchantCubit extends Cubit<MerchantState> {
  final MerchantRepository _repository;
  StreamSubscription<dynamic>? _authSubscription;

  /// Vrai tant que l'espace commerçant n'a pas encore été présenté depuis
  /// le lancement. Consommé une seule fois : passé ce point, le commerçant
  /// navigue librement entre son espace et l'application cliente sans être
  /// ramené de force.
  bool _landingPending = true;

  MerchantCubit({MerchantRepository? repository})
    : _repository = repository ?? MerchantRepositoryImpl(),
      super(const MerchantUnknown()) {
    _authSubscription = SessionService.instance.authStateChanges.listen((_) {
      refresh();
    });
    refresh();
  }

  /// Variante sans branchement sur Supabase, pour les tests : la session
  /// n'existe pas hors de l'application, et un cubit qui interroge le
  /// réseau dès sa construction n'est pas observable.
  @visibleForTesting
  MerchantCubit.forTest(MerchantRepository repository)
    : _repository = repository,
      super(const MerchantUnknown());

  /// L'utilisateur a-t-il une session ? Isolé pour que les tests puissent
  /// répondre sans Supabase.
  @visibleForTesting
  bool get isSignedIn => SessionService.instance.isLoggedIn;

  /// L'espace doit-il être ouvert d'emblée ? Vrai une seule fois, quand on
  /// vient d'apprendre que l'utilisateur est commerçant.
  bool consumeLanding() {
    if (!_landingPending) return false;
    if (state is! MerchantReady) return false;
    _landingPending = false;
    return true;
  }

  Future<void> refresh() async {
    if (!isSignedIn) {
      _landingPending = true;
      emit(const NotAMerchant());
      return;
    }

    try {
      final space = await _repository.getSpace();
      if (isClosed) return;
      emit(
        space.isMerchant
            ? MerchantReady(space)
            : NotAMerchant(application: space.application),
      );
    } catch (e) {
      if (isClosed) return;
      // Un espace commerçant injoignable ne doit pas bloquer l'application
      // pour un client : on retombe simplement du côté client.
      emit(const NotAMerchant());
    }
  }

  /// Dépose la demande. Renvoie `null` en cas de succès, sinon le message
  /// d'erreur à afficher — le formulaire décide quoi en faire.
  Future<String?> apply({
    required String businessName,
    required String categorySlug,
    required String address,
    required String phone,
    String? description,
  }) async {
    emit(const MerchantLoading());
    try {
      final space = await _repository.apply(
        businessName: businessName,
        categorySlug: categorySlug,
        address: address,
        phone: phone,
        description: description,
      );
      if (isClosed) return null;
      emit(
        space.isMerchant
            ? MerchantReady(space)
            : NotAMerchant(application: space.application),
      );
      return space.isMerchant ? null : 'Votre demande est en cours d\'examen.';
    } catch (e) {
      if (isClosed) return null;
      await refresh();
      return _message(e);
    }
  }

  Future<String?> createOffer(OfferDraft draft) =>
      _mutate(() => _repository.createOffer(draft));

  Future<String?> updateOffer(String offerId, OfferDraft draft) =>
      _mutate(() => _repository.updateOffer(offerId, draft));

  Future<String?> setOfferActive(String offerId, bool isActive) =>
      _mutate(() => _repository.setOfferActive(offerId, isActive));

  Future<String?> updateOrderStatus(String orderId, String status) =>
      _mutate(() => _repository.updateOrderStatus(orderId, status));

  Future<String?> updateReservationStatus(String id, String status) =>
      _mutate(() => _repository.updateReservationStatus(id, status));

  /// Exécute une écriture puis relit l'espace.
  ///
  /// On ne modifie jamais l'état localement : les compteurs du tableau de
  /// bord sont calculés par le serveur, et les recalculer ici en parallèle
  /// serait deux vérités pour une même chose.
  Future<String?> _mutate(Future<void> Function() action) async {
    final current = state;
    if (current is MerchantReady) {
      emit(MerchantReady(current.space, isWorking: true));
    }
    try {
      await action();
      await refresh();
      return null;
    } catch (e) {
      if (current is MerchantReady && !isClosed) {
        emit(MerchantReady(current.space));
      }
      return _message(e);
    }
  }

  String _message(Object error) {
    if (error is MerchantException) return error.message;
    return 'Opération impossible pour le moment.';
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
