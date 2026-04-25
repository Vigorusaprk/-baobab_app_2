import 'dart:convert';

class Vehicle {
  final String id;
  final String businessId;
  final String name;
  final String type;
  final double dailyPrice;
  final List<String> features;
  final String imageUrl;
  final int availableQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.businessId,
    required this.name,
    required this.type,
    required this.dailyPrice,
    required this.features,
    required this.imageUrl,
    required this.availableQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Parse features en gérant String JSON ou List
    List<String> parseFeatures(dynamic features) {
      if (features == null) return [];
      if (features is List) {
        return features.map((e) => e.toString()).toList();
      }
      if (features is String) {
        // Essayer de décoder si c'est du JSON
        if (features.startsWith('[') && features.endsWith(']')) {
          try {
            final decoded = jsonDecode(features) as List;
            return decoded.map((e) => e.toString()).toList();
          } catch (_) {
            return [];
          }
        }
        // Sinon, traiter comme une simple chaîne
        return [features];
      }
      return [];
    }

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Vehicle(
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      dailyPrice: parseDouble(json['daily_price'] ?? json['price']),
      features: parseFeatures(json['features']),
      imageUrl: json['image_url']?.toString() ?? '',
      availableQuantity: parseInt(json['available_quantity']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'type': type,
      'daily_price': dailyPrice,
      'features': features,
      'image_url': imageUrl,
      'available_quantity': availableQuantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}