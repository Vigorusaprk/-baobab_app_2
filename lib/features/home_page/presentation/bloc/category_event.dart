part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {}

class SelectCategory extends CategoryEvent {
  final String category; // Nom d'affichage de la catégorie

  const SelectCategory(this.category);

  @override
  List<Object> get props => [category];
}