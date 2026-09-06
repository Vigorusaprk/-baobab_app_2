import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_pop_up.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'merchant_agenda_parts.dart';
part 'merchant_agenda_row.dart';

/// L'agenda : les rendez-vous d'une journée, dans l'ordre des heures.
///
/// La liste des réservations reçues répond à « qu'est-ce qui est arrivé ? ».
/// Elle ne répond pas à « qu'est-ce que je fais aujourd'hui ? » — pour cela
/// il faut l'ordre du temps, et les trous entre deux rendez-vous.
///
/// Une semaine de pastilles en tête, un jour à l'écran : sur un téléphone, la
/// grille hebdomadaire d'un agenda de bureau ne laisse plus rien de lisible.
class MerchantAgenda extends StatefulWidget {
  const MerchantAgenda({super.key, required this.reservations});

  final List<ReceivedReservation> reservations;

  @override
  State<MerchantAgenda> createState() => _MerchantAgendaState();
}

class _MerchantAgendaState extends State<MerchantAgenda> {
  late DateTime _day;

  /// Combien de jours la barre du haut propose. Deux semaines : au-delà, on
  /// passe par le sélecteur de date.
  static const int _span = 14;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  List<ReceivedReservation> _of(DateTime day) {
    final list = widget.reservations
        .where(
          (r) =>
              r.date != null &&
              r.date!.year == day.year &&
              r.date!.month == day.month &&
              r.date!.day == day.day &&
              r.status != ReservationStatus.cancelled,
        )
        .toList();
    list.sort((a, b) => a.date!.compareTo(b.date!));
    return list;
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _day = DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today = DateTime.now();
    final days = [
      for (var i = 0; i < _span; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
    final ofDay = _of(_day);

    return Column(
      children: [
        // La barre des jours : le compte sous chaque date dit où le travail
        // se trouve, sans avoir à ouvrir chaque journée.
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.appPaddingValue,
              vertical: AppDimens.small,
            ),
            itemCount: days.length + 1,
            separatorBuilder: (_, _) => AppDimens.spacerSmallWidth,
            itemBuilder: (context, index) {
              if (index == days.length) {
                return _CalendarButton(onTap: _pickDay);
              }
              final day = days[index];
              return _DayChip(
                day: day,
                count: _of(day).length,
                selected: _isSame(day, _day),
                isToday: index == 0,
                onTap: () => setState(() => _day = day),
              );
            },
          ),
        ),
        Divider(height: 0.7, color: scheme.outlineVariant),
        Expanded(
          child: ofDay.isEmpty
              ? MerchantEmptyState(
                  icon: Icons.event_available_outlined,
                  title: _isSame(_day, today)
                      ? 'Rien aujourd\'hui'
                      : 'Rien ce jour-là',
                  message:
                      'Les rendez-vous confirmés et en attente apparaissent '
                      'ici, dans l\'ordre des heures.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.appPaddingValue,
                    AppDimens.medium,
                    AppDimens.appPaddingValue,
                    100,
                  ),
                  itemCount: ofDay.length,
                  separatorBuilder: (_, _) => AppDimens.spacerSmall,
                  itemBuilder: (context, index) =>
                      _AgendaRow(reservation: ofDay[index]),
                ),
        ),
      ],
    );
  }

  static bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
