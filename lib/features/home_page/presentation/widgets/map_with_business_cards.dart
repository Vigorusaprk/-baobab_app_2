import 'package:baobabe_0_2/features/home_page/domain/entities/business_match.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/location_filter.dart';
import 'package:flutter/material.dart';
import 'results_map_view.dart';
import 'business_card_placeholder.dart';

/// Layout de base : carte en plein écran + rangée de cartes business
/// flottante en bas, scrollable horizontalement. Juste la structure —
/// aucun style final sur les cartes, à toi de les remplir.
class MapWithBusinessCards extends StatelessWidget {
  final LocationFilter userLocation;
  final List<BusinessMatch> matches;
  final ValueChanged<BusinessMatch> onCardTap;
  final ValueChanged<BusinessMatch> onMarkerTap;

  const MapWithBusinessCards({
    Key? key,
    required this.userLocation,
    required this.matches,
    required this.onCardTap,
    required this.onMarkerTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Carte en fond, prend tout l'espace disponible.
        Positioned.fill(
          child: ResultsMapView(
            userLocation: userLocation,
            matches: matches,
            onMarkerTap: onMarkerTap,
          ),
        ),

        // Rangée de cartes business, flottante en bas.
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: SizedBox(
            height: 140,
            child: matches.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      return BusinessCardPlaceholder(
                        onTap: () => onCardTap(match),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
