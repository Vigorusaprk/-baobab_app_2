import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/movie.dart';

class MovieApiService {
  final SupabaseClient _supabase;

  MovieApiService([SupabaseClient? supabase])
    : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Movie>> getMoviesByCinema(String cinemaId) async {
    try {
      final response = await _supabase
          .from('movies')
          .select('*, showtimes(*)')
          .eq('business_id', cinemaId);

      return (response as List<dynamic>)
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des films : $e');
    }
  }
}
