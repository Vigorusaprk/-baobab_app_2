import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoomDateSelectors extends StatelessWidget {
  final DateTime? checkIn;
  final DateTime? checkOut;
  final VoidCallback onSelectCheckIn;
  final VoidCallback onSelectCheckOut;

  const RoomDateSelectors({
    super.key,
    required this.checkIn,
    required this.checkOut,
    required this.onSelectCheckIn,
    required this.onSelectCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _dateTile(
            label: 'Arrivée',
            date: checkIn,
            onTap: onSelectCheckIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _dateTile(
            label: 'Départ',
            date: checkOut,
            onTap: onSelectCheckOut,
          ),
        ),
      ],
    );
  }

  Widget _dateTile({required String label, required DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormat('dd/MM/yyyy').format(date) : label,
                style: TextStyle(color: date != null ? Colors.black : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
