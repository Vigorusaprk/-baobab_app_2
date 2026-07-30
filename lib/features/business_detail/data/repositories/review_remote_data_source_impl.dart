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
      // Insertion directe dans la table 'reviews' de ta base de données PostgreSQL
      await _supabase.from('reviews').insert({
        'business_id': businessId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      throw Exception('Erreur Supabase lors de la soumission de l\'avis : $e');
    }
  }

  @override
  Future<List<Review>> getReviews(String businessId) async {
    try {
      // Récupération des avis triés par date de création décroissante
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur Supabase lors de la récupération des avis : $e');
    }
  }
}
