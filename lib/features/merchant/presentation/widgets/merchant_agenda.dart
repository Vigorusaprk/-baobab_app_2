import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
      setState(
        () => _day = DateTime(picked.year, picked.month, picked.day),
      );
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

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.count,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final int count;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Material(
      color: selected ? scheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Container(
          width: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : isToday
                  ? scheme.primary
                  : scheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('E', 'fr_FR').format(day),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                '${day.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
              // Le compte ne s'affiche que s'il y a quelque chose : un « 0 »
              // sous chaque jour vide fait un mur de zéros.
              if (count > 0)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.onPrimary.withValues(alpha: 0.22)
                        : scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      AppDimens.borderRadiusFull,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected ? scheme.onPrimary : scheme.primary,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                )
              else
                const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarButton extends StatelessWidget {
  const _CalendarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Container(
          width: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Icon(Icons.calendar_month_outlined, color: scheme.primary),
        ),
      ),
    );
  }
}

/// Un rendez-vous : l'heure d'abord, puis qui et quoi.
class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.reservation});

  final ReceivedReservation reservation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final other = OtherTheme.of(context);
    final pending = reservation.status == ReservationStatus.pending;

    return MerchantCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.date == null
                    ? '--:--'
                    : DateFormat('HH:mm').format(reservation.date!),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              if (reservation.quantity > 1)
                Text(
                  '×${reservation.quantity}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          AppDimens.spacerMediumWidth,
          Container(width: 2, height: 40, color: scheme.primaryContainer),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppDimens.spacerMini,
                Text(
                  reservation.customer?.name ?? 'Client',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (pending) ...[
                  AppDimens.spacerSmall,
                  Row(
                    children: [
                      _MiniAction(
                        label: 'Confirmer',
                        icon: Icons.check_rounded,
                        onTap: () => context
                            .read<MerchantCubit>()
                            .updateReservationStatus(
                              reservation.id,
                              'confirmed',
                            ),
                      ),
                      AppDimens.spacerSmallWidth,
                      _MiniAction(
                        label: 'Refuser',
                        icon: Icons.close_rounded,
                        tint: scheme.error,
                        onTap: () => context
                            .read<MerchantCubit>()
                            .updateReservationStatus(
                              reservation.id,
                              'cancelled',
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          AppDimens.spacerSmallWidth,
          StatusChip(
            label: reservation.status.label,
            color: pending
                ? other.onWarningContainer
                : other.onSuccessContainer,
            surface: pending ? other.warningContainer : other.successContainer,
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tint,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tint ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              AppDimens.spacerMiniWidth,
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
