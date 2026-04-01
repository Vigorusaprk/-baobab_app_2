import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() async {
    return Category.allCategories;
  }

  @override
  Future<Category> getCategoryByType(BusinessType type) async {
    return Category.allCategories.firstWhere(
          (cat) => cat.type == type,
      orElse: () => Category.allCategories.first, // Retourne "Tout" par défaut
    );
  }
}