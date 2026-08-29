import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_filter.dart';
import '../../domain/entities/business_match.dart';

abstract class BudgetFinderState extends Equatable {
  const BudgetFinderState();
  @override
  List<Object?> get props => [];
}

class BudgetFinderInitial extends BudgetFinderState {
  const BudgetFinderInitial();
}

class BudgetFinderLoading extends BudgetFinderState {
  const BudgetFinderLoading();
}

class BudgetFinderLoaded extends BudgetFinderState {
  final List<BusinessMatch> matches;
  final BudgetFilter budget;

  const BudgetFinderLoaded({required this.matches, required this.budget});

  BudgetFinderLoaded copyWith({
    List<BusinessMatch>? matches,
    BudgetFilter? budget,
  }) {
    return BudgetFinderLoaded(
      matches: matches ?? this.matches,
      budget: budget ?? this.budget,
    );
  }

  @override
  List<Object?> get props => [matches, budget];
}

class BudgetFinderError extends BudgetFinderState {
  final String message;
  const BudgetFinderError(this.message);
  @override
  List<Object?> get props => [message];
}
