import 'package:baobabe_0_2/core/services/metrics_service.dart';
import 'package:baobabe_0_2/features/business_detail/data/offer_detail_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_detail.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class OfferDetailState extends Equatable {
  const OfferDetailState();

  @override
  List<Object?> get props => [];
}

class OfferDetailLoading extends OfferDetailState {
  const OfferDetailLoading();
}

class OfferDetailError extends OfferDetailState {
  final String message;

  const OfferDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class OfferDetailLoaded extends OfferDetailState {
  final OfferDetail detail;

  /// Combien l'utilisateur en veut. Toujours au moins 1 : la page parle
  /// d'une offre précise, pas d'un panier vide.
  final int quantity;

  /// Date retenue quand l'offre n'en impose pas.
  final DateTime? chosenDate;

  const OfferDetailLoaded(this.detail, {this.quantity = 1, this.chosenDate});

  OfferDetailLoaded copyWith({
    OfferDetail? detail,
    int? quantity,
    DateTime? chosenDate,
  }) {
    return OfferDetailLoaded(
      detail ?? this.detail,
      quantity: quantity ?? this.quantity,
      chosenDate: chosenDate ?? this.chosenDate,
    );
  }

  /// L'offre impose-t-elle sa date (séance, concert) ou l'utilisateur
  /// doit-il en choisir une (table, soin, chambre) ?
  bool get needsDateChoice =>
      detail.offer.isBookable && !detail.offer.hasFixedDate;

  bool get isDateMissing => needsDateChoice && chosenDate == null;

  double get total => detail.offer.price * quantity;

  @override
  List<Object?> get props => [detail, quantity, chosenDate];
}

/// Pilote la fiche d'une offre : sa lecture, puis sa commande ou sa
/// réservation.
///
/// C'est ici que se joue l'achat depuis la refonte : la fiche du commerçant
/// ne porte plus de boutons d'action, elle présente son catalogue et laisse
/// chaque offre parler pour elle-même.
class OfferDetailCubit extends Cubit<OfferDetailState> {
  final OfferDetailApiService _service;
  final String offerId;

  OfferDetailCubit({required this.offerId, OfferDetailApiService? service})
    : _service = service ?? OfferDetailApiService(),
      super(const OfferDetailLoading());

  Future<void> load() async {
    emit(const OfferDetailLoading());
    try {
      final detail = await _service.getDetail(offerId);
      if (isClosed) return;
      emit(OfferDetailLoaded(detail));

      // Une fiche ouverte se compte, ici plutôt que dans l'écran : c'est la
      // réponse du serveur qui porte le commerce, l'écran ne connaît que
      // l'identifiant de l'offre. Rien n'est attendu.
      final businessId = detail.offer.businessId;
      if (businessId != null) {
        MetricsService.instance.view(
          businessId: businessId,
          offerId: detail.offer.id,
        );
      }
    } on OfferDetailException catch (e) {
      if (!isClosed) emit(OfferDetailError(e.message));
    } catch (_) {
      if (!isClosed) {
        emit(const OfferDetailError('Cette offre n\'a pas pu être chargée.'));
      }
    }
  }

  void setQuantity(int quantity) {
    final current = state;
    if (current is! OfferDetailLoaded) return;

    // La jauge de places borne la quantité : proposer d'en prendre plus
    // qu'il n'en reste ne mène qu'à un refus au moment de valider.
    final maximum = current.detail.remainingCapacity;
    final clamped = maximum == null
        ? quantity.clamp(1, 99)
        : quantity.clamp(1, maximum < 1 ? 1 : maximum);
    emit(current.copyWith(quantity: clamped));
  }

  void setDate(DateTime date) {
    final current = state;
    if (current is! OfferDetailLoaded) return;
    emit(current.copyWith(chosenDate: date));
  }

  /// Relit la fiche **sans repasser par le squelette**.
  ///
  /// C'est la différence avec [load] : celui-ci émet `OfferDetailLoading`,
  /// ce qui est juste au premier affichage et faux après une commande — la
  /// page entière redevenait un squelette alors que l'utilisateur venait
  /// seulement d'appuyer sur un bouton, et rien à l'écran ne disait que sa
  /// commande était partie.
  ///
  /// Sert après une validation : la jauge de places a bougé, et le serveur
  /// reste seul juge de ce qui reste.
  Future<void> refresh() async {
    final current = state;
    if (current is! OfferDetailLoaded) return;
    try {
      final detail = await _service.getDetail(offerId);
      if (isClosed) return;
      emit(current.copyWith(detail: detail));
    } catch (_) {
      // Un rafraîchissement manqué laisse la fiche telle quelle : elle est
      // simplement d'un instant en retard, ce qui vaut mieux qu'une erreur
      // en travers d'une commande qui vient de réussir.
    }
  }
}
