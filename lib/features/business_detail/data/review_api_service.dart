import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewApiService {
  final SupabaseClient _supabase;

  ReviewApiService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// [userId] n'est plus transmis au serveur : l'Edge Function résout
  /// l'auteur de l'avis depuis le JWT de la requête (plus sûr que de faire
  /// confiance à une valeur envoyée par le client). Gardé dans la signature
  /// pour ne pas casser les appelants existants.
  ///
  /// [offerId] vise une offre précise : l'avis note alors ce qui a été
  /// consommé, et la note du commerce se recalcule comme la moyenne des
  /// avis reçus par ses offres.
  Future<void> submitReview(
    String businessId,
    String userId,
    int rating,
    String? comment, {
    String? offerId,
  }) async {
    try {
      await _supabase.functions.invoke(
        'create-review',
        method: HttpMethod.post,
        body: {
          'businessId': businessId,
          'rating': rating,
          'comment': comment,
          if (offerId != null) 'offerId': offerId,
        },
      );
    } catch (e) {
      throw Exception('Erreur de soumission d\'avis : $e');
    }
  }

  Future<List<Review>> getReviews(String businessId, {int page = 1}) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-reviews-business',
        method: HttpMethod.get,
        queryParameters: {'businessId': businessId, 'page': '$page'},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur de récupération des avis : $e');
    }
  }
}
