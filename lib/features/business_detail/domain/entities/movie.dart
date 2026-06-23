import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String businessId;
  final String title;
  final int duration;
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
      id: movieToInt(json['id']) ?? 0,
      businessId: json['business_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: movieToInt(json['duration']) ?? 0,
      genre: json['genre']?.toString(),
      releaseDate: json['release_date'] != null ? DateTime.tryParse(json['release_date'].toString()) : null,
      synopsis: json['synopsis']?.toString(),
      posterUrl: json['poster_url']?.toString(),
      rating: movieToDouble(json['rating']) ?? 0.0,
      showtimes: showtimesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'title': title,
      'duration': duration,
      'genre': genre,
      'release_date': releaseDate?.toIso8601String(),
      'synopsis': synopsis,
      'poster_url': posterUrl,
      'rating': rating,
      'showtimes': showtimes.map((s) => s.toJson()).toList(),
    };
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
      id: movieToInt(json['id']) ?? 0,
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      room: json['room']?.toString() ?? '',
      price: movieToDouble(json['price']) ?? 0.0,
      availableSeats: movieToInt(json['available_seats']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'room': room,
      'price': price,
      'available_seats': availableSeats,
    };
  }

  @override
  List<Object?> get props => [id, startTime];
}

int? movieToInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? movieToDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}