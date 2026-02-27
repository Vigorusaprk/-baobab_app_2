import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/entities/category_entity.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Retourner les nouvelles catégories
    return Category.allCategories;
  }

  @override
  Future<Category> getCategoryByName(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Rechercher la catégorie par nom (name) ou displayName
    final foundCategory = Category.allCategories.firstWhere(
          (category) =>
      category.name.toLowerCase() == name.toLowerCase() ||
          category.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => Category.allCategories.first, // Retourne "Tout" par défaut
    );

    return foundCategory;
  }

  @override
  Future<Category> getCategoryByBusinessType(BusinessType type) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Utiliser la méthode statique fromBusinessType qui existe maintenant
    return Category.fromBusinessType(type);
  }
}