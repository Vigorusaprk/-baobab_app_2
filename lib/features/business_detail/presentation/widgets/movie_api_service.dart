import 'package:baobabe_0_2/features/business_detail/domain/entities/movie.dart';
import 'package:dio/dio.dart';


class MovieApiService {
  final Dio _dio;
  final String _baseUrl;

  MovieApiService({Dio? dio, String baseUrl = 'http://10.0.2.2:3000/api'})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl;

  Future<List<Movie>> getMoviesByCinema(String cinemaId) async {
    try {
      final response = await _dio.get('$_baseUrl/businesses/$cinemaId/movies');
      final List data = response.data;
      return data.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des films : $e');
    }
  }
}