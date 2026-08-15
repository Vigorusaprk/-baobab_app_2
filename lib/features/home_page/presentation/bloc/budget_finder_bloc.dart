import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/budget_filter.dart';
import '../../domain/repositories/budget_finder_repository.dart';
import 'budget_finder_event.dart';
import 'budget_finder_state.dart';

class BudgetFinderBloc extends Bloc<BudgetFinderEvent, BudgetFinderState> {
  final BudgetFinderRepository repository;

  BudgetFinderBloc({required this.repository})
      : super(const BudgetFinderInitial()) {
    on<LoadBusinesses>(_onLoad);
    on<BudgetChanged>(_onBudgetChanged);
  }

  Future<void> _onLoad(
      LoadBusinesses event,
      Emitter<BudgetFinderState> emit,
      ) async {
    await _search(_currentBudget(), emit);
  }

  Future<void> _onBudgetChanged(
      BudgetChanged event,
      Emitter<BudgetFinderState> emit,
      ) async {
    await _search(event.budget, emit);
  }

  Future<void> _search(
      BudgetFilter budget,
      Emitter<BudgetFinderState> emit,
      ) async {
    emit(const BudgetFinderLoading());
    try {
      final matches = await repository.findMatches(budget);
      emit(BudgetFinderLoaded(matches: matches, budget: budget));
    } catch (e) {
      emit(BudgetFinderError('Recherche impossible : $e'));
    }
  }

  BudgetFilter _currentBudget() {
    final s = state;
    return s is BudgetFinderLoaded ? s.budget : const BudgetFilter.none();
  }
}