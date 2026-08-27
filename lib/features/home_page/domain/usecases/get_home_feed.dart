import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/business_repository.dart';

class GetHomeFeedParams {
  /// Catégorie sélectionnée, ou null pour "Tout".
  final String? category;

  const GetHomeFeedParams({this.category});
}

/// Charge, en un seul appel, l'ensemble des sections de la page d'accueil
/// pour une catégorie donnée.
class GetHomeFeed implements UseCase<HomeFeed, GetHomeFeedParams> {
  final BusinessRepository repository;

  GetHomeFeed(this.repository);

  @override
  Future<HomeFeed> call(GetHomeFeedParams params) async {
    return await repository.getHomeFeed(category: params.category);
  }
}
