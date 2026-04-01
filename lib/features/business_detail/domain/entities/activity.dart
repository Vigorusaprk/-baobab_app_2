class Activity {
  final String name;
  final double price;
  final int duration; // en minutes
  final String description;
  final String imageUrl;
  final String location; // lieu de l'activité

  Activity({
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.imageUrl,
    required this.location,
  });
}