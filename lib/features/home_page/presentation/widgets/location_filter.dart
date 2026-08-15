/// Filtre localisation. [label] est null quand la position vient du GPS,
/// renseigné quand l'utilisateur a choisi une adresse/zone manuellement
/// (utile pour afficher "Autour de Gombe" au lieu de coordonnées brutes).
class LocationFilter {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? label;
  final bool isFromGps;

  const LocationFilter({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 5,
    this.label,
    this.isFromGps = true,
  });

  LocationFilter copyWith({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? label,
    bool? isFromGps,
  }) {
    return LocationFilter(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      label: label ?? this.label,
      isFromGps: isFromGps ?? this.isFromGps,
    );
  }
}
