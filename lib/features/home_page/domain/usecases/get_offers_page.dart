import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/business_repository.dart';

class GetOffersPageParams {
  /// Section paginée demandée : `discover` (les mieux notées) ou `new`
  /// (les nouveautés, derrière « Voir plus »).
  final String section;
  final int page;
  final String? category;

  const GetOffersPageParams({
    required this.section,
    required this.page,
    this.category,
  });
}

/// Charge une page supplémentaire d'une section d'offres de l'accueil.
class GetOffersPage implements UseCase<OffersPage, GetOffersPageParams> {
  final BusinessRepository repository;

  GetOffersPage(this.repository);

  @override
  Future<OffersPage> call(GetOffersPageParams params) =>
      repository.getOffersPage(
        section: params.section,
        page: params.page,
        category: params.category,
      );
}
