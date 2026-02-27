part of 'business_bloc.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object> get props => [];
}

class BusinessInitial extends BusinessState {}

class BusinessLoading extends BusinessState {}

class BusinessLoaded extends BusinessState {
  final List<Business>  businesses;
  final String currentCategory;

  const BusinessLoaded({
    required this.businesses,
    required this.currentCategory,
  });

  @override
  List<Object> get props => [businesses, currentCategory];
}

class BusinessError extends BusinessState {
  final String message;

  const BusinessError({required this.message});

  @override
  List<Object> get props => [message];
}