part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {}

class SelectCategory extends CategoryEvent {
  final Category category; // Changé de String à Category
  const SelectCategory(this.category);

  @override
  List<Object> get props => [category];
}