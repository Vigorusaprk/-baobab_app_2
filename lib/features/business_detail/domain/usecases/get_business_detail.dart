import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import '../../../../core/usecases/usecase.dart';

class GetBusinessDetail implements UseCase<Business, String> {
  final BusinessRepository repository;

  GetBusinessDetail(this.repository);

  @override
  Future<Business> call(String businessId) async {
    return await repository.getBusinessDetail(businessId);
  }
}