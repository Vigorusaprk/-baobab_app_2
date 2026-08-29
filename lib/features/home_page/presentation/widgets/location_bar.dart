import 'package:baobabe_0_2/features/home_page/presentation/widgets/location_filter.dart';
import 'package:flutter/material.dart';

/// Barre compacte affichant la localisation active.
/// [onUseGps] relance la géoloc, [onEditManually] ouvre la saisie manuelle
/// (à toi de brancher un champ de recherche d'adresse, ex: package
/// `google_places_flutter` ou ton propre picker sur la carte).
class LocationBar extends StatelessWidget {
  final LocationFilter? location;
  final bool isLocating;
  final VoidCallback onUseGps;
  final VoidCallback onEditManually;

  const LocationBar({
    Key? key,
    required this.location,
    required this.isLocating,
    required this.onUseGps,
    required this.onEditManually,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isLocating
                  ? 'Localisation en cours...'
                  : (location?.label ??
                        (location?.isFromGps == true
                            ? 'Autour de moi'
                            : 'Choisir une zone')),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location, size: 20),
            tooltip: 'Utiliser ma position',
            onPressed: isLocating ? null : onUseGps,
          ),
          TextButton(onPressed: onEditManually, child: const Text('Modifier')),
        ],
      ),
    );
  }
}
