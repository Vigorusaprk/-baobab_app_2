import 'package:baobabe_0_2/core/usecases/usecase.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_by_category_use_case.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';


part 'business_event.dart';
part 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final GetBusinesses getBusinesses;
  final GetBusinessesByCategory getBusinessesByCategory;

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
      emit(BusinessLoaded(
        businesses: businesses,
        currentCategory: 'Tout',
      ));
    } catch (e) {
      emit(BusinessError(message: e.toString()));
    }
  }

  Future<void> _onLoadBusinessesByCategory(
      LoadBusinessesByCategory event,
      Emitter<BusinessState> emit,
      ) async {
    emit(BusinessLoading());
    try {
      final businesses = await getBusinessesByCategory(event.category);
      emit(BusinessLoaded(
        businesses: businesses,
        currentCategory: event.category,
      ));
    } catch (e) {
      emit(BusinessError(message: e.toString()));
    }
  }
}