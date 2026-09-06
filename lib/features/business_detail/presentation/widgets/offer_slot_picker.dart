import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/data/offer_slots_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_availability.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_parts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'offer_slot_picker_parts.dart';

/// Le choix du rendez-vous, quand le commerçant a déclaré ses créneaux.
///
/// Avant, le client choisissait **n'importe quelle** date et **n'importe
/// quelle** heure : 3 h du matin passait, et le commerçant découvrait le
/// rendez-vous impossible en ouvrant sa boîte. Le serveur refuse désormais
/// une date qui ne tombe pas sur un créneau déclaré — encore faut-il que le
/// client voie lesquels existent, plutôt que de deviner puis d'être refusé.
///
/// **Le choix libre reste** quand l'offre ne déclare rien : les offres
/// publiées avant les créneaux continuent de fonctionner sans que personne
/// ne les reprenne, et [OfferDateChoice] s'affiche alors comme avant.
class OfferSlotPicker extends StatefulWidget {
  const OfferSlotPicker({
    super.key,
    required this.offerId,
    required this.chosen,
    required this.onPickSlot,
    required this.onPickDay,
    required this.onOpenCalendar,
    this.service,
  });

  final String offerId;

  /// Le rendez-vous retenu, ou `null`.
  final DateTime? chosen;

  /// Un créneau touché : la date **et** l'heure sont connues, on ne demande
  /// plus rien.
  final ValueChanged<DateTime> onPickSlot;

  /// Choix libre : un jour touché, l'heure demandée ensuite.
  final ValueChanged<DateTime> onPickDay;

  /// Choix libre : le calendrier complet.
  final VoidCallback onOpenCalendar;

  /// Injectable pour les tests : sans cela, le sélecteur ne se pose pas sans
  /// un Supabase initialisé.
  final OfferSlotsApiService? service;

  @override
  State<OfferSlotPicker> createState() => _OfferSlotPickerState();
}

class _OfferSlotPickerState extends State<OfferSlotPicker> {
  late final OfferSlotsApiService _service =
      widget.service ?? OfferSlotsApiService();

  OfferAvailability? _availability;
  String? _error;
  DateTime? _day;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final availability = await _service.getAvailability(widget.offerId);
      if (!mounted) return;
      final days = availability.openDays;
      setState(() {
        _availability = availability;
        // Le premier jour ouvert est présélectionné : on n'ouvre pas une
        // page de créneaux sur une journée vide.
        _day = days.isEmpty ? null : days.first;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final availability = _availability;

    if (_error != null) return _Retry(message: _error!, onRetry: _load);
    if (availability == null) return const _SlotSkeleton();

    // Rien de déclaré : le client garde la main, comme avant.
    if (!availability.declaresSlots) {
      return OfferDateChoice(
        chosen: widget.chosen,
        onPickDay: widget.onPickDay,
        onOpenCalendar: widget.onOpenCalendar,
      );
    }

    final days = availability.openDays;
    if (days.isEmpty) return const _NoSlots();

    final day = _day ?? days.first;
    final slots = availability.slotsOn(day);

    // La référence à laquelle « il reste peu » se mesure. Sans elle, une
    // offre déclarée à une place affichait « dernière place » sous
    // *chaque* créneau : la mention perdait tout sens, puisqu'un créneau à
    // une place est soit libre, soit absent. On ne la montre donc que
    // lorsqu'il reste moins que d'habitude — c'est-à-dire que quelqu'un a
    // déjà pris quelque chose.
    final reference =
        availability.slotCapacity ??
        slots.fold<int>(
          0,
          (best, slot) => slot.remaining > best ? slot.remaining : best,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Jour'),
        AppDimens.spacerSmall,
        // Les jours ouverts, et eux seuls : proposer une pastille pour un
        // jour fermé, c'est faire toucher pour rien.
        SizedBox(
          height: OfferDateChoice.chipHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, _) => AppDimens.spacerSmallWidth,
            itemBuilder: (context, index) => SizedBox(
              width: 64,
              child: OfferDayChip(
                day: days[index],
                selected: _isSameDay(days[index], day),
                onTap: () => setState(() => _day = days[index]),
              ),
            ),
          ),
        ),
        AppDimens.spacerLarge,
        _Label('Heure'),
        AppDimens.spacerSmall,
        Wrap(
          spacing: AppDimens.small,
          runSpacing: AppDimens.small,
          children: [
            for (final slot in slots)
              _SlotChip(
                slot: slot,
                reference: reference,
                selected:
                    widget.chosen != null && _isSame(slot.at, widget.chosen!),
                onTap: () => widget.onPickSlot(slot.at),
              ),
          ],
        ),
        if (availability.durationMinutes != null) ...[
          AppDimens.spacerSmall,
          _Hint(
            text:
                'Chaque rendez-vous dure '
                '${_duration(availability.durationMinutes!)}.',
          ),
        ],
      ],
    );
  }

  static String _duration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (rest == 0) return '$hours h';
    return '$hours h $rest';
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _isSame(DateTime a, DateTime b) =>
      _isSameDay(a, b) && a.hour == b.hour && a.minute == b.minute;
}
