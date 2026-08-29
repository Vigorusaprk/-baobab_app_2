import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BusinessHoursSection extends StatelessWidget {
  final Business business;

  const BusinessHoursSection({super.key, required this.business});

  // Ordre souhaité des jours (commence par Lundi)
  static const List<String> orderedDays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  @override
  Widget build(BuildContext context) {
    // Récupérer les entrées de la map et les trier selon l'ordre défini
    final entries = business.openingHours.entries.toList();
    entries.sort((a, b) {
      final indexA = orderedDays.indexWhere(
        (day) => day.toLowerCase() == a.key.trim().toLowerCase(),
      );
      final indexB = orderedDays.indexWhere(
        (day) => day.toLowerCase() == b.key.trim().toLowerCase(),
      );
      // Si un jour n'est pas trouvé, le mettre à la fin (index 999)
      return (indexA == -1 ? 999 : indexA).compareTo(
        indexB == -1 ? 999 : indexB,
      );
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radius20),
      ),
      child: Column(
        children: entries.map((entry) {
          final bool isToday = _isToday(entry.key);

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isToday
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isToday)
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SvgPicture.asset(
                          "assets/icons/opening-hours.svg",
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  entry.value,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

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
    return dayKey.trim().toLowerCase() ==
        daysInFrench[now.weekday]?.toLowerCase();
  }
}
