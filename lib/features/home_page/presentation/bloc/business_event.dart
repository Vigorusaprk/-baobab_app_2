part of 'business_bloc.dart';

abstract class BusinessEvent extends Equatable {
  const BusinessEvent();

  @override
  List<Object> get props => [];
}

class LoadBusinesses extends BusinessEvent {}

/// Recharge l'accueil pour une catégorie, désignée par son slug.
///
/// Un slug plutôt qu'une valeur d'énumération : les catégories viennent du
/// serveur, et une catégorie créée en base doit fonctionner sans que
/// l'application connaisse son nom à la compilation.
class LoadBusinessesBySlug extends BusinessEvent {
  final String slug;

  const LoadBusinessesBySlug(this.slug);

  @override
  List<Object> get props => [slug];
}

/// Demande la page suivante du flux actuellement affiché (scroll infini).
/// Le bloc ignore l'événement si une page est déjà en cours de chargement
/// ou s'il n'y a plus rien à charger — la vue n'a rien à savoir de ça, elle
/// se contente de "prévenir" quand l'utilisateur approche de la fin.
class LoadMoreBusinesses extends BusinessEvent {
  const LoadMoreBusinesses();
}
