import '../../../../core/usecases/usecase.dart';
import '../repositories/business_repository.dart';

class ToggleFavorite implements UseCase<void, String> {
  final BusinessRepository repository;

  ToggleFavorite(this.repository);

  @override
  Future<void> call(String businessId) async {
    await repository.toggleFavorite(businessId);
  }
}