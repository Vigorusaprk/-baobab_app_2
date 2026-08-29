import 'package:baobabe_0_2/features/home_page/domain/entities/business_match.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/location_filter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Carte affichant les résultats. Marker vert = dans le budget,
/// marker orange = hors budget mais dans le rayon (visible quand même,
/// pour laisser le choix à l'utilisateur plutôt que de le cacher).
class ResultsMapView extends StatelessWidget {
  final LocationFilter userLocation;
  final List<BusinessMatch> matches;
  final ValueChanged<BusinessMatch> onMarkerTap;

  const ResultsMapView({
    Key? key,
    required this.userLocation,
    required this.matches,
    required this.onMarkerTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(userLocation.latitude, userLocation.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Vous'),
      ),
      ...matches
          // Sécurité : si jamais un match sans coordonnées arrive ici,
          // on l'ignore plutôt que de crasher (le repository est censé
          // déjà filtrer, mais on ne veut pas dépendre de ça pour la carte).
          .where(
            (match) =>
                match.business.latitude != null &&
                match.business.longitude != null,
          )
          .map((match) {
            return Marker(
              markerId: MarkerId(match.business.id),
              position: LatLng(
                match.business.latitude!,
                match.business.longitude!,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                match.matchesBudget
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueOrange,
              ),
              infoWindow: InfoWindow(title: match.business.name),
              onTap: () => onMarkerTap(match),
            );
          }),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(userLocation.latitude, userLocation.longitude),
        zoom: 13,
      ),
      markers: markers,
      myLocationEnabled: userLocation.isFromGps,
      myLocationButtonEnabled: false,
    );
  }
}
