import 'package:baobabe_0_2/features/business_detail/data/data_sources/remote_datasource/review_remote_data_source.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient _supabase;

  ReviewRemoteDataSourceImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<void> submitReview({
    required String businessId,
    required String userId,
    required int rating,
    String? comment,
  }) async {
    try {
      // L'Edge Function résout l'auteur de l'avis depuis le JWT, pas depuis
      // userId (gardé dans la signature de l'interface).
      await _supabase.functions.invoke(
        'create-review',
        method: HttpMethod.post,
        body: {'businessId': businessId, 'rating': rating, 'comment': comment},
      );
    } catch (e) {
      throw Exception('Erreur lors de la soumission de l\'avis : $e');
    }
  }

  @override
  Future<List<Review>> getReviews(String businessId) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-reviews-business',
        method: HttpMethod.get,
        queryParameters: {'businessId': businessId},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des avis : $e');
    }
  }
}
