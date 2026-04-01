class Room {
  final int id;
  final String businessId;
  final String roomType;
  final double pricePerNight;
  final int capacity;
  final int availableQuantity;
  final String? description;
  final Map<String, dynamic>? amenities;
  final List<String>? images;

  Room({
    required this.id,
    required this.businessId,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.availableQuantity,
    this.description,
    this.amenities,
    this.images,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    // Fonctions utilitaires
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Room(
      id: _toInt(json['id']),
      businessId: json['business_id']?.toString() ?? '',
      roomType: json['room_type']?.toString() ?? '',
      pricePerNight: _toDouble(json['price_per_night']),
      capacity: _toInt(json['capacity']),
      availableQuantity: _toInt(json['available_quantity']),
      description: json['description']?.toString(),
      amenities: json['amenities'] is Map ? Map<String, dynamic>.from(json['amenities']) : null,
      images: json['images'] is List ? List<String>.from(json['images'].map((i) => i.toString())) : null,
    );
  }
}