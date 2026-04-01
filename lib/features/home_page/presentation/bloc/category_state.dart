part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<Category> categories;
  final Category selectedCategory;

  const CategoriesLoaded({
    required this.categories,
    required this.selectedCategory,
  });

  @override
  List<Object> get props => [categories, selectedCategory];
}