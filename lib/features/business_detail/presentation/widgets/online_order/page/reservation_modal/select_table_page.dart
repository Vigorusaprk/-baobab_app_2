import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SelectTablePage extends StatelessWidget {
  final List<String> floors;
  final String selectedFloor;
  final ValueChanged<String> onFloorSelected;
  final String? selectedTable;
  final ValueChanged<String> onTableSelected;
  final VoidCallback? onNext;

  const SelectTablePage({
    Key? key,
    required this.floors,
    required this.selectedFloor,
    required this.onFloorSelected,
    required this.selectedTable,
    required this.onTableSelected,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Choisissez votre table préférée',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: floors.map((floor) {
                bool isSelected = selectedFloor == floor;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(floor),
                    selected: isSelected,
                    onSelected: (selected) {
                      onFloorSelected(floor);
                    },
                    backgroundColor: AppColors.background,
                    selectedColor: AppColors.secondary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).canvasColor
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final tableNumber = 1 + index;
              final isSelected = selectedTable == tableNumber.toString();
              final isReserved = [2, 5, 8].contains(tableNumber);

              return GestureDetector(
                onTap: isReserved
                    ? null
                    : () {
                        onTableSelected(tableNumber.toString());
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: isReserved
                        ? AppColors.textSecondary
                        : (isSelected
                              ? AppColors.secondary
                              : AppColors.background),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_restaurant,
                              size: 30,
                              color: isReserved
                                  ? AppColors.white
                                  : (isSelected
                                        ? AppColors.white
                                        : AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Table $tableNumber',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isReserved
                                    ? AppColors.white
                                    : (isSelected
                                          ? AppColors.white
                                          : AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isReserved)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Réservée',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedTable != null
                    ? AppColors.secondary
                    : AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              child: Text(
                "Réserver une table",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedTable != null
                      ? AppColors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
