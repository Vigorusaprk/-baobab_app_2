part of 'business_detail_bloc.dart';

abstract class BusinessDetailState extends Equatable {
  const BusinessDetailState();

  @override
  List<Object> get props => [];
}

class BusinessDetailInitial extends BusinessDetailState {}

class BusinessDetailLoading extends BusinessDetailState {}

class BusinessDetailLoaded extends BusinessDetailState {
  final Business business; // CHANGÉ: BusinessDetailEntity → BusinessEntity

  const BusinessDetailLoaded({required this.business});

  @override
  List<Object> get props => [business];
}

class BusinessDetailError extends BusinessDetailState {
  final String message;

  const BusinessDetailError({required this.message});

  @override
  List<Object> get props => [message];
}