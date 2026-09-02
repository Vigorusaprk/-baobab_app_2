import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_detail.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_selection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ce qu'on valide : une commande, ou une réservation.
enum CheckoutKind {
  order,
  booking;

  bool get isOrder => this == CheckoutKind.order;
}

/// L'état de la validation, **et rien d'autre**.
///
/// Il vivait dans `OfferDetailCubit`, mêlé à la lecture de la fiche. Deux
/// conséquences visibles à l'écran :
///
/// - une validation réussie appelait `load()`, qui repasse par
///   `OfferDetailLoading` : toute la page redevenait un squelette alors que
///   l'utilisateur venait seulement d'appuyer sur un bouton ;
/// - « en train de valider » était un champ de l'état de la fiche, donc
///   chaque frappe sur la quantité et chaque relecture le traversaient.
///
/// Séparés, la fiche se lit et la validation se valide. La fiche ne bouge
/// plus pendant qu'on commande.
sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

/// Rien en cours.
class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();
}

class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting();
}

class CheckoutSucceeded extends CheckoutState {
  const CheckoutSucceeded(this.kind);

  final CheckoutKind kind;

  @override
  List<Object?> get props => [kind];
}

class CheckoutFailed extends CheckoutState {
  const CheckoutFailed(this.message);

  /// Le message du serveur, tel quel : les fonctions répondent en français
  /// et parlent du métier (« Il ne reste que 2 place(s) »).
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Passe la commande ou la réservation. Ne lit rien, n'affiche rien.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    OfferSelection? selection,
    AppSessionUser? Function()? session,
  }) : _selection = selection,
       _session = session ?? _currentUser,
       super(const CheckoutIdle());

  /// Injectable pour les tests ; sinon un panier neuf par validation.
  final OfferSelection? _selection;

  /// Qui valide. Injectable, et c'est tout l'intérêt de la séparation : un
  /// cubit qui lit un singleton global ne se teste pas.
  final AppSessionUser? Function() _session;

  static AppSessionUser? _currentUser() => SessionService.instance.currentUser;

  /// [deliveryAddress] vient de la feuille d'adresse : sans elle le
  /// commerçant recevait une commande sans savoir où la livrer.
  /// [contactPhone] joue le même rôle pour une réservation, qui ne se livre
  /// pas mais doit pouvoir se confirmer par téléphone.
  ///
  /// Aucun montant n'est transmis : le serveur lit le prix en base, vérifie
  /// la disponibilité et refuse une date passée.
  Future<void> submit({
    required OfferDetail detail,
    required int quantity,
    DateTime? chosenDate,
    String? deliveryAddress,
    String? contactPhone,
  }) async {
    if (state is CheckoutSubmitting) return;

    final user = _session();
    if (user == null) {
      emit(const CheckoutFailed('Connectez-vous pour continuer.'));
      return;
    }

    final offer = detail.offer;
    final businessId = offer.businessId ?? detail.merchant?.id;
    if (businessId == null) {
      emit(const CheckoutFailed('Ce commerçant est introuvable.'));
      return;
    }

    emit(const CheckoutSubmitting());
    try {
      final selection = _selection ?? OfferSelection();
      selection.setQuantity(offer, quantity);
      selection.chosenDate = chosenDate;

      if (offer.isOrderable) {
        await selection.submitOrder(
          businessId: businessId,
          offers: [offer],
          userId: user.id,
          deliveryAddress: deliveryAddress,
        );
      } else {
        await selection.submitBooking(
          offers: [offer],
          contactPhone: contactPhone,
        );
      }

      if (isClosed) return;
      emit(
        CheckoutSucceeded(
          offer.isOrderable ? CheckoutKind.order : CheckoutKind.booking,
        ),
      );
    } catch (e) {
      if (!isClosed) emit(CheckoutFailed(_message(e)));
    }
  }

  /// Ramène à l'état neutre, une fois l'issue montrée à l'écran.
  ///
  /// Sans cela, revenir sur la fiche rejouerait l'animation de réussite ou
  /// le message d'erreur d'une validation déjà passée.
  void acknowledge() {
    if (!isClosed) emit(const CheckoutIdle());
  }

  /// Les fonctions serveur répondent en français et parlent du métier :
  /// ces messages sont faits pour être montrés, pas remplacés par un
  /// « une erreur est survenue ».
  String _message(Object error) {
    final cleaned = error
        .toString()
        .replaceAll(RegExp(r'(?:Exception:\s*)+'), '')
        .trim();
    return cleaned.isEmpty ? 'Opération impossible pour le moment.' : cleaned;
  }
}
