part of 'business_detail_bloc.dart';

abstract class BusinessDetailEvent extends Equatable {
  const BusinessDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadBusinessDetail extends BusinessDetailEvent {
  final String businessId;
  const LoadBusinessDetail(this.businessId);
  @override
  List<Object> get props => [businessId];
}

// ✅ Événement pour créer une réservation
class MakeReservation extends BusinessDetailEvent {
  final Reservation reservation;
  const MakeReservation(this.reservation);
  @override
  List<Object> get props => [reservation];
}
