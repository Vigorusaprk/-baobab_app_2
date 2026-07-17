import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SelectActivitiesPage extends StatelessWidget {
  final bool isSmallScreen;
  final double horizontalPadding;
  final List<dynamic> activities;
  final List<String> selectedActivities;
  final double totalAmount;
  final ValueChanged<String> onToggleActivity;
  final VoidCallback? onNext;

  const SelectActivitiesPage({
    Key? key,
    required this.isSmallScreen,
    required this.horizontalPadding,
    required this.activities,
    required this.selectedActivities,
    required this.totalAmount,
    required this.onToggleActivity,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final name = activity['name'] ?? '';
              final price = (activity['price'] as num?)?.toDouble() ?? 0.0;
              final duration = activity['duration'] ?? 0;
              final description = activity['description'] ?? '';
              final location = activity['location'] ?? '';
              final isSelected = selectedActivities.contains(name);

              return Container(
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(width: 2, color: AppColors.primary) : Border.all(width: 2.5, color: Colors.transparent),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: InkWell(
                  onTap: () => onToggleActivity(name),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => onToggleActivity(name),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(location, style: TextStyle(fontSize: isSmallScreen ? 11 : 13))]),
                              Text('Durée: $duration min', style: TextStyle(fontSize: isSmallScreen ? 11 : 13)),
                              Text('\$$price / personne', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(description, style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
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
              Text('${selectedActivities.length} activité(s) sélectionnée(s)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
              Text('Total: \$${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: isSmallScreen ? 14 : 16)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedActivities.isNotEmpty ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedActivities.isNotEmpty ? AppColors.primary : Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Continuer", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: selectedActivities.isNotEmpty ? Colors.white : Colors.grey[600])),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
      ],
    );
  }
}
