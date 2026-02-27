import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/business_repository.dart';

class GetBusinesses implements UseCase<List<Business>, NoParams> {
  final BusinessRepository repository;

  GetBusinesses(this.repository);

  @override
  Future<List<Business>> call(NoParams params) async {
    return await repository.getBusinesses();
  }
}