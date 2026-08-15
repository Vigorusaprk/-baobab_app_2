import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_filter.dart';

abstract class BudgetFinderEvent extends Equatable {
  const BudgetFinderEvent();
  @override
  List<Object?> get props => [];
}

/// Charge (ou recharge) la liste des business avec le budget actuel.
class LoadBusinesses extends BudgetFinderEvent {
  const LoadBusinesses();
}

/// Changement du filtre budget (tranche et/ou montant précis), via le
/// formulaire de filtres.
class BudgetChanged extends BudgetFinderEvent {
  final BudgetFilter budget;
  const BudgetChanged(this.budget);
  @override
  List<Object?> get props => [budget];
}