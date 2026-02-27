part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<String> categories; // Noms d'affichage des catégories
  final String selectedCategory;

  const CategoriesLoaded({
    required this.categories,
    this.selectedCategory = 'Tout',
  });

  @override
  List<Object> get props => [categories, selectedCategory];
}