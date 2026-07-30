import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_by_category_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';

part 'business_event.dart';
part 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final GetBusinesses getBusinesses;
  final GetBusinessesByCategory
  getBusinessesByCategory; // Disponible si tu décides de repasser en remote plus tard

  List<Business> _allBusinesses = [];

  BusinessBloc({
    required this.getBusinesses,
    required this.getBusinessesByCategory,
  }) : super(BusinessInitial()) {
    on<LoadBusinesses>(_onLoadBusinesses);
    on<LoadBusinessesByCategory>(_onLoadBusinessesByCategory);
  }

  Future<void> _onLoadBusinesses(
    LoadBusinesses event,
    Emitter<BusinessState> emit,
  ) async {
    emit(BusinessLoading());
    try {
      final businesses = await getBusinesses(NoParams());
      _allBusinesses = businesses;
      emit(
        BusinessLoaded(
          businesses: businesses,
          currentCategory: BusinessType.all,
        ),
      );
    } catch (e) {
      emit(BusinessError("Erreur lors du chargement : ${e.toString()}"));
    }
  }

  void _onLoadBusinessesByCategory(
    LoadBusinessesByCategory event,
    Emitter<BusinessState> emit,
  ) {
    emit(BusinessLoading());

    // Si la catégorie est 'all' ou 'other', on réinitialise l'affichage avec tout le cache local
    if (event.category == BusinessType.all ||
        event.category == BusinessType.other) {
      emit(
        BusinessLoaded(
          businesses: List.from(_allBusinesses),
          currentCategory: event.category,
        ),
      );
    } else {
      // Filtrage synchrone en mémoire ultra rapide
      final filtered = _allBusinesses.where((business) {
        return business.type.name.toLowerCase() ==
            event.category.name.toLowerCase();
      }).toList();

      emit(
        BusinessLoaded(businesses: filtered, currentCategory: event.category),
      );
    }
  }
}
