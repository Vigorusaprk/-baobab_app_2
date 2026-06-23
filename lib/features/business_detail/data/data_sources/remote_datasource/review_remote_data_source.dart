import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart'; // Ajuste l'import selon ton arborescence

abstract class ReviewRemoteDataSource {
  Future<void> submitReview({
    required String businessId,
    required String userId,
    required int rating,
    String? comment,
  });
  Future<List<Review>> getReviews(String businessId);
}