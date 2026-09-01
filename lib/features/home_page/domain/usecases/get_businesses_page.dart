import 'package:baobabe_0_2/features/home_page/domain/entities/businesses_page.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/business_repository.dart';

class GetBusinessesPageParams {
  final int page;
  final String? category;

  /// Ce que l'utilisateur a tapé. Cherché en base, jamais sur la page déjà
  /// reçue : filtrer côté client ne porterait que sur les vingt premiers
  /// commerces, ce qui est faux dès qu'on fait défiler.
  final String? query;

  const GetBusinessesPageParams({
    required this.page,
    this.category,
    this.query,
  });
}

class GetBusinessesPage
    implements UseCase<BusinessesPage, GetBusinessesPageParams> {
  final BusinessRepository repository;

  GetBusinessesPage(this.repository);

  @override
  Future<BusinessesPage> call(GetBusinessesPageParams params) async {
    return await repository.getBusinessesPage(
      page: params.page,
      category: params.category,
      query: params.query,
    );
  }
}
