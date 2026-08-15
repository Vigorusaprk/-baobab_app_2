import 'package:baobabe_0_2/features/home_page/domain/repositories/mock_budget_finder_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/budget_filter.dart';
import '../bloc/budget_finder_bloc.dart';
import '../bloc/budget_finder_event.dart';
import '../bloc/budget_finder_state.dart';
import '../widgets/budget_filter_panel.dart';
import '../widgets/business_results_list.dart';

/// Page racine. TODO: remplacer MockBudgetFinderRepository() par
/// l'implémentation Supabase une fois branchée sur `business_with_avg_price`.
class BudgetFinderPage extends StatelessWidget {
  const BudgetFinderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BudgetFinderBloc(repository: MockBudgetFinderRepository())
        ..add(const LoadBusinesses()),
      child: const _BudgetFinderView(),
    );
  }
}

class _BudgetFinderView extends StatelessWidget {
  const _BudgetFinderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trouver un établissement')),
      body: BlocBuilder<BudgetFinderBloc, BudgetFinderState>(
        builder: (context, state) {
          final budget = state is BudgetFinderLoaded
              ? state.budget
              : const BudgetFilter.none();

          return Column(
            children: [
              const SizedBox(height: 12),
              // Formulaire de filtres budget.
              BudgetFilterPanel(
                budget: budget,
                onChanged: (newBudget) =>
                    context.read<BudgetFinderBloc>().add(BudgetChanged(newBudget)),
              ),
              const Divider(height: 24),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BudgetFinderState state) {
    if (state is BudgetFinderInitial || state is BudgetFinderLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is BudgetFinderError) {
      return Center(child: Text(state.message));
    }
    final loaded = state as BudgetFinderLoaded;
    return BusinessResultsList(
      matches: loaded.matches,
      onTap: (match) {
        // TODO: ouvrir les détails du business, ou une bottom sheet.
      },
    );
  }
}