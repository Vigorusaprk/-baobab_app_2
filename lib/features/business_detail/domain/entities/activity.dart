class Activity {
  final String name;
  final double price;
  final int duration; // en minutes
  final String description;
  final String imageUrl;
  final String location;

  Activity({
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.imageUrl,
    required this.location,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] is int
          ? json['duration']
          : (json['duration'] as num?)?.toInt() ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
      'image_url': imageUrl,
      'location': location,
    };
  }
}
