import '../../domain/entities/category_entity.dart';
import '../../domain/entities/business_entity.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category> getCategoryByType(BusinessType type);
}