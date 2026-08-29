import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:equatable/equatable.dart';

/// Catégorie de la marketplace, servie par le back (table `categories`) et
/// mise en cache localement.
///
/// [slug] est la valeur de référence : c'est elle qui est stockée dans
/// `business.type` et envoyée au serveur pour filtrer. [type] n'est qu'une
/// commodité pour le code existant qui raisonne encore sur l'énumération ;
/// une catégorie créée en base et inconnue de l'énumération reste
/// parfaitement fonctionnelle, seul son `type` retombe sur
/// [BusinessType.other].
class Category extends Equatable {
  final String id;
  final String slug;
  final String displayName;

  /// Nom d'icône Material, résolu à l'affichage.
  final String icon;

  /// Couleur d'accent au format `0xAARRGGBB`.
  final String color;

  final int sortOrder;

  const Category({
    required this.id,
    required this.slug,
    required this.displayName,
    this.icon = 'explore',
    this.color = '0xFF2E7D54',
    this.sortOrder = 0,
  });

  /// Équivalent dans l'énumération historique, ou [BusinessType.other] pour
  /// une catégorie que l'application ne connaît pas encore.
  BusinessType get type => BusinessType.values.firstWhere(
    (t) => t.name == slug,
    orElse: () => BusinessType.other,
  );

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      displayName: json['label']?.toString() ?? json['slug']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'explore',
      color: json['color']?.toString() ?? '0xFF2E7D54',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'label': displayName,
    'icon': icon,
    'color': color,
    'sort_order': sortOrder,
  };

  /// Catégorie synthétique "Tout", ajoutée côté client en tête de liste.
  /// Elle n'existe pas en base : ce n'est pas une catégorie de commerce mais
  /// l'absence de filtre.
  static const Category all = Category(
    id: 'all',
    slug: 'all',
    displayName: 'Tout',
    icon: 'explore',
    color: '0xFF2E7D54',
  );

  /// Repli utilisé uniquement au tout premier lancement sans réseau ni
  /// cache : l'écran affiche alors les catégories historiques plutôt
  /// qu'une bande vide. Dès qu'un appel aboutit, le serveur fait autorité.
  static const List<Category> fallback = [
    Category(
      id: 'f1',
      slug: 'restaurant',
      displayName: 'Restaurants',
      icon: 'restaurant',
      color: '0xFFFF6B57',
      sortOrder: 10,
    ),
    Category(
      id: 'f2',
      slug: 'fastFood',
      displayName: 'Fast Food',
      icon: 'fastfood',
      color: '0xFFFF9800',
      sortOrder: 20,
    ),
    Category(
      id: 'f3',
      slug: 'shopping',
      displayName: 'Shopping',
      icon: 'shopping_bag',
      color: '0xFF00B8D9',
      sortOrder: 30,
    ),
    Category(
      id: 'f4',
      slug: 'mall',
      displayName: 'Centres Commerciaux',
      icon: 'store_mall_directory',
      color: '0xFF8B5CF6',
      sortOrder: 40,
    ),
    Category(
      id: 'f5',
      slug: 'hotel',
      displayName: 'Hôtels',
      icon: 'hotel',
      color: '0xFF536DFE',
      sortOrder: 50,
    ),
    Category(
      id: 'f6',
      slug: 'carRental',
      displayName: 'Location Voiture',
      icon: 'directions_car',
      color: '0xFF3BB273',
      sortOrder: 60,
    ),
    Category(
      id: 'f7',
      slug: 'travelAgency',
      displayName: 'Voyage',
      icon: 'card_travel',
      color: '0xFF00C2A8',
      sortOrder: 70,
    ),
    Category(
      id: 'f8',
      slug: 'spa',
      displayName: 'Spa',
      icon: 'spa',
      color: '0xFF2DD4BF',
      sortOrder: 80,
    ),
    Category(
      id: 'f9',
      slug: 'cinema',
      displayName: 'Cinema',
      icon: 'movie',
      color: '0xFFE64980',
      sortOrder: 90,
    ),
    Category(
      id: 'f10',
      slug: 'tourism',
      displayName: 'Tourisme',
      icon: 'tour_rounded',
      color: '0xFF7950F2',
      sortOrder: 100,
    ),
  ];

  /// Libellé lisible d'une catégorie à partir de son slug, pour les titres
  /// d'écran. [known] est la liste chargée depuis le serveur.
  static String displayNameForSlug(String slug, List<Category> known) {
    if (slug.isEmpty || slug == 'all' || slug == 'other') {
      return 'Tous les commerces';
    }
    for (final c in known) {
      if (c.slug == slug) return c.displayName;
    }
    return 'Commerces';
  }

  @override
  List<Object?> get props => [id, slug, displayName, icon, color, sortOrder];
}
