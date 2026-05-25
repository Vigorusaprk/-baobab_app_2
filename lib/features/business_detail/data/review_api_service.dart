import 'package:dio/dio.dart';
import '../domain/entities/review.dart';

class ReviewApiService {
  final Dio dio;
  // La baseUrl est déjà configurée dans le Dio global
  ReviewApiService({required this.dio});

  Future<void> submitReview(String businessId, String userId, int rating, String? comment) async {
    await dio.post('/reviews', data: {
      'business_id': businessId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<List<Review>> getReviews(String businessId) async {
    final response = await dio.get('/businesses/$businessId/reviews');
    final List data = response.data;
    return data.map((json) => Review.fromJson(json)).toList();
  }
}