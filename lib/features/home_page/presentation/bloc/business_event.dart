part of 'business_bloc.dart';

abstract class BusinessEvent extends Equatable {
  const BusinessEvent();

  @override
  List<Object> get props => [];
}

class LoadBusinesses extends BusinessEvent {}

class LoadBusinessesByCategory extends BusinessEvent {
  final BusinessType category;

  const LoadBusinessesByCategory(this.category);

  @override
  List<Object> get props => [category];
}