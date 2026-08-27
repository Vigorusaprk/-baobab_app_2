import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

// Vérifiez que CategoryState est bien reconnu ici
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc({required this.categoryRepository}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SelectCategory>(_onSelectCategory);

    add(LoadCategories());
  }

  void _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await categoryRepository.getCategories();
      emit(
        CategoriesLoaded(
          categories: categories,
          // "Tout" est la sélection de départ : on n'impose pas la
          // première catégorie de la liste, qui filtrerait d'emblée.
          selectedCategory: Category.all,
        ),
      );
    } catch (e) {
      emit(
        CategoriesLoaded(
          categories: Category.fallback,
          selectedCategory: Category.all,
        ),
      );
    }
  }

  void _onSelectCategory(SelectCategory event, Emitter<CategoryState> emit) {
    if (state is CategoriesLoaded) {
      final currentState = state as CategoriesLoaded;
      emit(
        CategoriesLoaded(
          categories: currentState.categories,
          selectedCategory: event.category,
        ),
      );
    }
  }
}
