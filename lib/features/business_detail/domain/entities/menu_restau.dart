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

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      businessId: json['business_id']?.toString() ?? '',
      itemName: json['item_name'] ?? '',
      itemCategory: json['item_category'] ?? '',
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
      'item_name': itemName,
      'item_category': itemCategory,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'ingredients': ingredients,
      'is_available': isAvailable,
    };
  }
}