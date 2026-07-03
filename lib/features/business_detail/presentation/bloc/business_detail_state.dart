part of 'business_detail_bloc.dart';

enum BusinessDetailStatus { initial, loading, loaded, error }
enum ReservationStatus { initial, loading, success, error }

class BusinessDetailState extends Equatable {
  final Business? business;
  final BusinessDetailStatus detailStatus;
  final String? detailErrorMessage;
  final List<OrderItem> cartItems;

  final ReservationStatus reservationStatus;
  final String? reservationErrorMessage;

  const BusinessDetailState({
    this.business,
    this.detailStatus = BusinessDetailStatus.initial,
    this.detailErrorMessage,
    this.reservationStatus = ReservationStatus.initial,
    this.reservationErrorMessage,
    this.cartItems = const [],
  });

  BusinessDetailState copyWith({
    Business? business,
    BusinessDetailStatus? detailStatus,
    String? detailErrorMessage,
    ReservationStatus? reservationStatus,
    String? reservationErrorMessage,
    List<OrderItem>? cartItems,
  }) {
    return BusinessDetailState(
      business: business ?? this.business,
      detailStatus: detailStatus ?? this.detailStatus,
      detailErrorMessage: detailErrorMessage ?? this.detailErrorMessage,
      reservationStatus: reservationStatus ?? this.reservationStatus,
      reservationErrorMessage: reservationErrorMessage ?? this.reservationErrorMessage,
      cartItems: cartItems ?? this.cartItems,
    );
  }

  @override
  List<Object?> get props => [
    business,
    detailStatus,
    detailErrorMessage,
    reservationStatus,
    reservationErrorMessage,
    cartItems,
  ];
}