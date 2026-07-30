import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SelectTreatmentPage extends StatelessWidget {
  final bool isSmallScreen;
  final double horizontalPadding;
  final List<dynamic> treatments;
  final List<String> selectedTreatments;
  final double totalAmount;
  final ValueChanged<String> onToggleTreatment;
  final VoidCallback? onNext;

  const SelectTreatmentPage({
    Key? key,
    required this.isSmallScreen,
    required this.horizontalPadding,
    required this.treatments,
    required this.selectedTreatments,
    required this.totalAmount,
    required this.onToggleTreatment,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: treatments.length,
            itemBuilder: (context, index) {
              final treatment = treatments[index];
              final name = treatment is Map
                  ? (treatment['name']?.toString() ?? '')
                  : treatment.toString();
              final price = treatment is Map
                  ? (treatment['price'] as num?)?.toDouble() ?? 0.0
                  : 0.0;
              final duration = treatment is Map
                  ? (treatment['duration'] as int?) ?? 0
                  : 0;
              final description = treatment is Map
                  ? (treatment['description']?.toString() ?? '')
                  : '';
              final isSelected = selectedTreatments.contains(name);

              return Container(
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(width: 2, color: AppColors.primary)
                      : Border.all(width: 2.5, color: AppColors.transparent),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => onToggleTreatment(name),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => onToggleTreatment(name),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (duration > 0)
                                Text(
                                  'Durée: $duration min',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 13,
                                  ),
                                ),
                              if (price > 0)
                                Text(
                                  '\$$price',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedTreatments.length} soin(s) sélectionné(s)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              Text(
                'Total: \$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedTreatments.isNotEmpty ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedTreatments.isNotEmpty
                    ? AppColors.primary
                    : AppColors.textSecondary,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Continuer",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: selectedTreatments.isNotEmpty
                      ? AppColors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
      ],
    );
  }
}
