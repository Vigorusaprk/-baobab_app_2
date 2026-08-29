import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class BusinessSpecificSection extends StatelessWidget {
  final Business business;

  const BusinessSpecificSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    // Récupération des données spécifiques filtrées (uniquement ce qui est disponible)
    final features = _getAvailableFeatures();

    if (features.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Commodités & Services",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        // Grille Wrap pour un affichage fluide des badges
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: features
              .map((feature) => _buildFeatureChip(context, feature))
              .toList(),
        ),
      ],
    );
  }

  /// Construit un badge stylisé pour chaque caractéristique
  Widget _buildFeatureChip(BuildContext context, _FeatureData feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            feature.icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            feature.label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Logique pour extraire uniquement les services disponibles (true)
  List<_FeatureData> _getAvailableFeatures() {
    final List<_FeatureData> available = [];
    final data = business.specificData;

    // Mapping des clés de données vers des labels lisibles et icônes
    final map = {
      'wifi': _FeatureData("WiFi Gratuit", Icons.wifi_rounded),
      'parking': _FeatureData("Parking", Icons.local_parking_rounded),
      'hasDelivery': _FeatureData("Livraison", Icons.delivery_dining_rounded),
      'hasTakeout': _FeatureData("À emporter", Icons.shopping_basket_rounded),
      'hasAC': _FeatureData("Climatisation", Icons.ac_unit_rounded),
      'hasPlayArea': _FeatureData("Espace Enfant", Icons.child_care_rounded),
      'hasFoodCourt': _FeatureData("Food Court", Icons.fastfood_rounded),
      'isAccessible': _FeatureData("Accessible", Icons.accessible_rounded),
    };

    data.forEach((key, value) {
      if (value == true && map.containsKey(key)) {
        available.add(map[key]!);
      }
    });

    return available;
  }
}

/// Modèle simple pour structurer les données de caractéristiques
class _FeatureData {
  final String label;
  final IconData icon;
  _FeatureData(this.label, this.icon);
}
