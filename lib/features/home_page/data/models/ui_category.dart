import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';

/// Habillage d'affichage d'une [Category].
///
/// L'icône et la couleur viennent désormais du serveur sous forme de
/// chaînes ; elles sont résolues ici. Une catégorie créée en base avec une
/// icône inconnue de l'application reste affichable — elle retombe
/// simplement sur l'icône générique au lieu de faire échouer l'écran.
class UICategory {
  final Category category;

  const UICategory(this.category);

  /// Icônes autorisées pour une catégorie. Flutter élague les icônes non
  /// référencées à la compilation : elles doivent donc être nommées
  /// explicitement ici, une résolution dynamique par code ne fonctionnerait
  /// pas en release.
  static const Map<String, IconData> _icons = {
    'restaurant': Icons.restaurant,
    'fastfood': Icons.fastfood,
    'shopping_bag': Icons.shopping_bag,
    'store_mall_directory': Icons.store_mall_directory,
    'hotel': Icons.hotel,
    'directions_car': Icons.directions_car,
    'card_travel': Icons.card_travel,
    'spa': Icons.spa,
    'movie': Icons.movie,
    'tour_rounded': Icons.tour_rounded,
    'confirmation_number': Icons.confirmation_number,
    'auto_awesome': Icons.auto_awesome,
    'handyman': Icons.handyman,
    'local_grocery_store': Icons.local_grocery_store,
    'fitness_center': Icons.fitness_center,
    'medical_services': Icons.medical_services,
    'school': Icons.school,
    'celebration': Icons.celebration,
    'explore': Icons.explore,
  };

  IconData get icon => _icons[category.icon] ?? Icons.explore;

  /// La couleur envoyée par le serveur, ou le vert de la marque si elle est
  /// illisible.
  Color color(BuildContext context) =>
      _parseColor(category.color) ?? Theme.of(context).colorScheme.secondary;

  static Color? _parseColor(String value) {
    final normalized = value
        .trim()
        .replaceFirst('#', '')
        .replaceFirst('0x', '');
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return null;
    // Une valeur sans canal alpha (RRGGBB) est rendue opaque.
    return Color(normalized.length <= 6 ? 0xFF000000 | parsed : parsed);
  }
}
