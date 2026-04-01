
class MenuItem {
  final int id;
  final String businessId;
  final String itemName;
  final String itemCategory;
  final double price;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.businessId,
    required this.itemName,
    required this.itemCategory,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    this.isAvailable = true,
  });

  // Convertit le JSON de PostgreSQL vers l'objet Flutter
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      businessId: json['business_id'], // Mappe le snake_case SQL
      itemName: json['item_name'],
      itemCategory: json['item_category'],
      // Gestion sécurisée du type Decimal/Double
      price: (json['price'] is String)
          ? double.parse(json['price'])
          : (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      // Gestion du tableau TEXT[] de PostgreSQL
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : [],
      isAvailable: json['is_available'] ?? true,
    );
  }
}