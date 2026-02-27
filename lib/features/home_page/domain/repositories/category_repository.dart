import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category> getCategoryByName(String name);
  Future<Category> getCategoryByBusinessType(BusinessType type);
}