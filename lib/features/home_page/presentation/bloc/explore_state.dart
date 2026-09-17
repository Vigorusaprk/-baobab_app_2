part of 'explore_cubit.dart';

enum ExploreStatus { initial, loading, ready, failure }

/// Ce que l'écran d'où l'on vient demande à Explorer de faire en arrivant.
///
/// Une seule valeur à la fois, et non deux drapeaux : la barre de recherche et
/// le bouton de filtre de l'accueil s'excluent, et deux booléens auraient
/// laissé exister un état que personne ne peut produire.
enum ExploreIntent {
  /// Ouvrir la feuille de filtres — le bouton de l'accueil.
  openFilters,

  /// Donner le focus au champ : l'utilisateur a touché la barre de recherche
  /// de l'accueil, il veut taper. Sans cela il devait toucher une seconde
  /// fois, une fois arrivé.
  focusSearch,
}

/// L'état d'Explorer : un jeu de critères, et ce que le serveur a répondu.
class ExploreState extends Equatable {
  const ExploreState({
    this.status = ExploreStatus.initial,
    this.message,
    this.pendingIntent,
    this.filters = const BusinessSearchFilters(),
    this.businesses = const [],
    this.hasMore = false,
    this.page = 1,
    this.loadingMore = false,
  });

  final ExploreStatus status;

  /// Message écrit à montrer en cas d'échec. Jamais une exception.
  final String? message;

  /// Ce que l'écran doit faire dès son affichage, à la demande de l'accueil.
  ///
  /// Consommé par l'écran puis remis à `null`. Le passer par la route aurait
  /// mis un paramètre dans l'URL, qui serait resté après coup et aurait rejoué
  /// l'action à chaque retour sur l'onglet.
  final ExploreIntent? pendingIntent;

  final BusinessSearchFilters filters;
  final List<Business> businesses;
  final bool hasMore;

  /// La dernière page reçue du serveur.
  ///
  /// Suivie explicitement plutôt que déduite du nombre de commerces : une
  /// page n'est pleine que si le serveur avait de quoi la remplir, et la
  /// division redemandait alors la page déjà lue.
  final int page;

  /// Une page suivante en route.
  final bool loadingMore;

  ExploreState copyWith({
    ExploreStatus? status,
    String? message,
    ExploreIntent? pendingIntent,
    BusinessSearchFilters? filters,
    List<Business>? businesses,
    bool? hasMore,
    int? page,
    bool? loadingMore,
    bool clearMessage = false,
    bool clearIntent = false,
  }) => ExploreState(
    status: status ?? this.status,
    message: clearMessage ? null : (message ?? this.message),
    pendingIntent: clearIntent ? null : (pendingIntent ?? this.pendingIntent),
    filters: filters ?? this.filters,
    businesses: businesses ?? this.businesses,
    hasMore: hasMore ?? this.hasMore,
    page: page ?? this.page,
    loadingMore: loadingMore ?? this.loadingMore,
  );

  @override
  List<Object?> get props => [
    status,
    message,
    pendingIntent,
    filters,
    businesses,
    hasMore,
    page,
    loadingMore,
  ];
}
