import 'package:baobabe_0_2/core/usecases/usecase.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';

class GetMenuByBusiness implements UseCase<List<MenuItem>, String> {
  final BusinessRepository repository;

  GetMenuByBusiness(this.repository);

  @override
  Future<List<MenuItem>> call(String businessId) async {
    // businessId ici est l'identifiant VARCHAR(50) de votre table business
    return await repository.getMenuByBusiness(businessId);
  }
}