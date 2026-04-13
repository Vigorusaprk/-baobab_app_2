import 'package:dio/dio.dart';
import '../domain/entities/review.dart';

class ReviewApiService {
  final Dio dio;
  final String baseUrl;

  ReviewApiService({required this.dio, this.baseUrl = 'http://10.0.2.2:3000/api'});

  Future<void> submitReview(String businessId, String userId, int rating, String? comment) async {
    await dio.post('$baseUrl/reviews', data: {
      'business_id': businessId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<List<Review>> getReviews(String businessId) async {
    final response = await dio.get('$baseUrl/businesses/$businessId/reviews');
    final List data = response.data;
    return data.map((json) => Review.fromJson(json)).toList();
  }
}