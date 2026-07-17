import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SelectDestinationPage extends StatelessWidget {
  final bool isSmallScreen;
  final double horizontalPadding;
  final String? destination;
  final ValueChanged<String?> onDestinationChanged;
  final VoidCallback? onNext;

  const SelectDestinationPage({
    Key? key,
    required this.isSmallScreen,
    required this.horizontalPadding,
    required this.destination,
    required this.onDestinationChanged,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Destination", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: destination,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.white,
            ),
            hint: const Text("Choisir une destination"),
            items: const [
              DropdownMenuItem(value: "Paris", child: Text("Paris")),
              DropdownMenuItem(value: "Kinshasa", child: Text("Kinshasa")),
            ],
            onChanged: onDestinationChanged,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: destination != null ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: destination != null ? AppColors.primary : Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Continuer", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: destination != null ? Colors.white : Colors.grey[600])),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }
}
