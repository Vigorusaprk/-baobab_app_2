import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String businessId;
  final String title;
  final int duration; // en minutes
  final String? genre;
  final DateTime? releaseDate;
  final String? synopsis;
  final String? posterUrl;
  final double rating;
  final List<Showtime> showtimes;

  const Movie({
    required this.id,
    required this.businessId,
    required this.title,
    required this.duration,
    this.genre,
    this.releaseDate,
    this.synopsis,
    this.posterUrl,
    required this.rating,
    required this.showtimes,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final showtimesList = (json['showtimes'] as List?)
        ?.map((s) => Showtime.fromJson(s as Map<String, dynamic>))
        .toList() ??
        [];

    return Movie(
      id: _toInt(json['id']) ?? 0,
      businessId: json['business_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: _toInt(json['duration']) ?? 0,
      genre: json['genre']?.toString(),
      releaseDate: json['release_date'] != null ? DateTime.tryParse(json['release_date'].toString()) : null,
      synopsis: json['synopsis']?.toString(),
      posterUrl: json['poster_url']?.toString(),
      rating: _toDouble(json['rating']) ?? 0.0,
      showtimes: showtimesList,
    );
  }

  @override
  List<Object?> get props => [id, title];
}

class Showtime extends Equatable {
  final int id;
  final DateTime startTime;
  final String room;
  final double price;
  final int availableSeats;

  const Showtime({
    required this.id,
    required this.startTime,
    required this.room,
    required this.price,
    required this.availableSeats,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(
      id: _toInt(json['id']) ?? 0,
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      room: json['room']?.toString() ?? '',
      price: _toDouble(json['price']) ?? 0.0,
      availableSeats: _toInt(json['available_seats']) ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, startTime];
}

// Fonctions utilitaires pour convertir en toute sécurité
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}