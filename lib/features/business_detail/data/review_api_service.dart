import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewApiService {
  final SupabaseClient _supabase;

  ReviewApiService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<void> submitReview(
    String businessId,
    String userId,
    int rating,
    String? comment,
  ) async {
    try {
      await _supabase.from('reviews').insert({
        'business_id': businessId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      throw Exception('Erreur de soumission d\'avis Supabase : $e');
    }
  }

  Future<List<Review>> getReviews(String businessId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur de récupération des avis Supabase : $e');
    }
  }
}
