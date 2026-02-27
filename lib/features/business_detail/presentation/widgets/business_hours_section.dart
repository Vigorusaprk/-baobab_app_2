import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';


class BusinessHoursSection extends StatelessWidget {
  final Business business;

  const BusinessHoursSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: business.openingHours.entries.map((entry) {
          final bool isToday = _isToday(entry.key);

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              // Mise en avant du jour actuel
              color: isToday ? const Color(0xFF254D32).withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isToday)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.access_time_filled_rounded, size: 16, color: Color(0xFF254D32)),
                      ),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday ? const Color(0xFF254D32) : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    color: isToday ? const Color(0xFF254D32) : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Vérifie si la clé du jour correspond au jour actuel de la semaine
  bool _isToday(String dayKey) {
    final now = DateTime.now();
    final daysInFrench = {
      1: 'Lundi',
      2: 'Mardi',
      3: 'Mercredi',
      4: 'Jeudi',
      5: 'Vendredi',
      6: 'Samedi',
      7: 'Dimanche',
    };

    // On normalise en minuscules pour éviter les erreurs de frappe dans les données
    return dayKey.trim().toLowerCase() == daysInFrench[now.weekday]?.toLowerCase();
  }
}