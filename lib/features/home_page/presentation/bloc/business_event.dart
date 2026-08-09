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

/// Demande la page suivante du flux actuellement affiché (scroll infini).
/// Le bloc ignore l'événement si une page est déjà en cours de chargement
/// ou s'il n'y a plus rien à charger — la vue n'a rien à savoir de ça, elle
/// se contente de "prévenir" quand l'utilisateur approche de la fin.
class LoadMoreBusinesses extends BusinessEvent {
  const LoadMoreBusinesses();
}
