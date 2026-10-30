/// Décide quand charger la prochaine page pendant le défilement.
class ExplorePagination {
  const ExplorePagination._();

  /// Garde le seuil historique : charger à partir de 90 % du défilement.
  static bool shouldLoadMore({
    required double pixels,
    required double maxScrollExtent,
    double threshold = 0.9,
  }) => pixels >= maxScrollExtent * threshold;
}
