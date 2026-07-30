class MenuItem {
  final String id; // CHANGÉ de int à String
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

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      // On convertit toujours l'ID en String pour accepter UUID ou int
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      itemName:
          json['name'] ?? '', // CORRIGÉ : correspond au nom de colonne "name"
      itemCategory:
          json['category'] ??
          '', // CORRIGÉ : correspond au nom de colonne "category"
      price: (json['price'] is String)
          ? double.parse(json['price'])
          : (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : [],
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': itemName,
      'category': itemCategory,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'ingredients': ingredients,
      'is_available': isAvailable,
    };
  }
}
