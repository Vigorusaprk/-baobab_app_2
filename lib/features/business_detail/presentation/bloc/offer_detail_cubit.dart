import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/business_detail/data/offer_detail_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_detail.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_selection.dart';
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

  /// Une validation est en cours. L'écran reste affiché — on ne renvoie pas
  /// l'utilisateur sur un squelette parce qu'il vient d'appuyer.
  final bool isSubmitting;

  const OfferDetailLoaded(
    this.detail, {
    this.quantity = 1,
    this.chosenDate,
    this.isSubmitting = false,
  });

  OfferDetailLoaded copyWith({
    int? quantity,
    DateTime? chosenDate,
    bool? isSubmitting,
  }) {
    return OfferDetailLoaded(
      detail,
      quantity: quantity ?? this.quantity,
      chosenDate: chosenDate ?? this.chosenDate,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  /// L'offre impose-t-elle sa date (séance, concert) ou l'utilisateur
  /// doit-il en choisir une (table, soin, chambre) ?
  bool get needsDateChoice =>
      detail.offer.isBookable && !detail.offer.hasFixedDate;

  bool get isDateMissing => needsDateChoice && chosenDate == null;

  double get total => detail.offer.price * quantity;

  @override
  List<Object?> get props => [detail, quantity, chosenDate, isSubmitting];
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

  OfferDetailCubit({
    required this.offerId,
    OfferDetailApiService? service,
  }) : _service = service ?? OfferDetailApiService(),
       super(const OfferDetailLoading());

  Future<void> load() async {
    emit(const OfferDetailLoading());
    try {
      final detail = await _service.getDetail(offerId);
      if (isClosed) return;
      emit(OfferDetailLoaded(detail));
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

  /// Valide l'achat. Renvoie `null` en cas de succès, sinon le message à
  /// afficher — l'écran décide quoi en faire.
  ///
  /// Aucun montant n'est transmis : le serveur lit le prix en base, vérifie
  /// la disponibilité et refuse une date passée.
  Future<String?> submit() async {
    final current = state;
    if (current is! OfferDetailLoaded) return null;

    final user = SessionService.instance.currentUser;
    if (user == null) return 'Connectez-vous pour continuer.';

    final offer = current.detail.offer;
    final businessId = offer.businessId ?? current.detail.merchant?.id;
    if (businessId == null) return 'Ce commerçant est introuvable.';

    emit(current.copyWith(isSubmitting: true));
    try {
      final selection = OfferSelection()
        ..setQuantity(offer, current.quantity)
        ..chosenDate = current.chosenDate;

      if (offer.isOrderable) {
        await selection.submitOrder(
          businessId: businessId,
          offers: [offer],
          userId: user.id,
        );
      } else {
        await selection.submitBooking(offers: [offer]);
      }

      // La jauge de places a bougé : on relit plutôt que de la décrémenter
      // ici, le serveur restant seul juge de ce qui reste.
      await load();
      return null;
    } catch (e) {
      if (!isClosed) emit(current.copyWith(isSubmitting: false));
      return _message(e);
    }
  }

  /// Les fonctions serveur répondent en français et parlent du métier
  /// (« Il ne reste que 2 place(s) ») : ces messages sont faits pour être
  /// montrés, pas remplacés par un « une erreur est survenue ».
  String _message(Object error) {
    final raw = error.toString();
    final marker = RegExp(r'(?:Exception:\s*)+');
    final cleaned = raw.replaceAll(marker, '').trim();
    return cleaned.isEmpty ? 'Opération impossible pour le moment.' : cleaned;
  }
}
