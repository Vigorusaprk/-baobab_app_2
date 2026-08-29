import 'package:baobabe_0_2/features/home_page/presentation/widgets/price_tier.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/budget_filter.dart';

/// Panneau de filtre budget : chips de tranche (€/€€/€€€) en haut,
/// slider de montant précis en dessous (facultatif, pour affiner).
class BudgetFilterPanel extends StatelessWidget {
  final BudgetFilter budget;
  final ValueChanged<BudgetFilter> onChanged;
  final double sliderMax;

  const BudgetFilterPanel({
    Key? key,
    required this.budget,
    required this.onChanged,
    this.sliderMax = 100000,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: PriceTier.values.map((tier) {
              final isSelected = budget.tier == tier;
              return ChoiceChip(
                label: Text(tier.label),
                selected: isSelected,
                onSelected: (_) => onChanged(
                  budget.copyWith(tier: tier, clearTier: isSelected),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RangeSlider(
            min: 0,
            max: sliderMax,
            divisions: 20,
            labels: RangeLabels(
              (budget.minAmount ?? 0).round().toString(),
              (budget.maxAmount ?? sliderMax).round().toString(),
            ),
            values: RangeValues(
              budget.minAmount ?? 0,
              budget.maxAmount ?? sliderMax,
            ),
            onChanged: (values) => onChanged(
              budget.copyWith(minAmount: values.start, maxAmount: values.end),
            ),
          ),
        ),
      ],
    );
  }
}
