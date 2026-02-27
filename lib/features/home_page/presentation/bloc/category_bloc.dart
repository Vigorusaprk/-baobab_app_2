import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc({required this.categoryRepository}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SelectCategory>(_onSelectCategory);

    // Charger les catégories au démarrage
    add(LoadCategories());
  }

  void _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());

    try {
      // Charger les catégories depuis le repository
      final categories = await categoryRepository.getCategories();

      // Convertir en noms d'affichage pour l'état
      final categoryNames = categories.map((c) => c.displayName).toList();

      emit(CategoriesLoaded(
        categories: categoryNames,
        selectedCategory: 'Tout',
      ));
    } catch (e) {
      // En cas d'erreur, utiliser les catégories par défaut
      final defaultCategories = Category.allCategories.map((c) => c.displayName).toList();

      emit(CategoriesLoaded(
        categories: defaultCategories,
        selectedCategory: 'Tout',
      ));
    }
  }

  void _onSelectCategory(SelectCategory event, Emitter<CategoryState> emit) {
    if (state is CategoriesLoaded) {
      final currentState = state as CategoriesLoaded;
      emit(CategoriesLoaded(
        categories: currentState.categories,
        selectedCategory: event.category,
      ));
    }
  }
}