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