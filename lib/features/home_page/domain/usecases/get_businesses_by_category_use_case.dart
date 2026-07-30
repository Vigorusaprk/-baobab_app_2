import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/business_repository.dart';

class GetBusinessesByCategory implements UseCase<List<Business>, String> {
  final BusinessRepository repository;

  GetBusinessesByCategory(this.repository);

  @override
  Future<List<Business>> call(String category) async {
    return await repository.getBusinessesByCategory(category);
  }
}
