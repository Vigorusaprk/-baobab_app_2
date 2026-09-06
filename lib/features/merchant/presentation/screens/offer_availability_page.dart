import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:baobabe_0_2/features/business_detail/data/offer_slots_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_availability.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'offer_availability_page_week.dart';
part 'offer_availability_page_edits.dart';
part 'offer_availability_page_parts.dart';

/// Les rendez-vous d'une offre : quand elle est ouverte, et pour combien de
/// monde à la fois.
///
/// Sans cet écran, le client proposait la date de son choix et le commerçant
/// recevait des demandes pour des heures où il est fermé — puis les refusait
/// une par une. Ce qui se déclare ici devient la **seule** chose que le
/// client peut choisir.
///
/// Déclaré **par offre** : une nuit d'hôtel, une coupe de trente minutes et
/// une soirée en terrasse ne tombent pas dans la même grille.
class OfferAvailabilityPage extends StatefulWidget {
  const OfferAvailabilityPage({super.key, required this.offer});

  final Offer offer;

  @override
  State<OfferAvailabilityPage> createState() => _OfferAvailabilityPageState();
}

class _OfferAvailabilityPageState extends State<OfferAvailabilityPage> {
  final _api = OfferSlotsApiService();

  /// Les durées qu'on choisit vraiment. Au-delà, le champ libre du serveur
  /// accepte n'importe quoi entre 5 minutes et 24 heures.
  static const List<int> _durations = [30, 45, 60, 90, 120, 240, 1440];

  int? _duration;
  int _capacity = 1;
  int _lead = 2;
  List<AvailabilityRule> _rules = [];
  List<AvailabilityException> _exceptions = [];

  OfferAvailability? _loaded;
  bool _saving = false;
  bool _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final availability = await _api.getAvailability(widget.offer.id);
      if (!mounted) return;
      setState(() {
        _loaded = availability;
        _duration = availability.durationMinutes;
        _capacity = availability.slotCapacity ?? 1;
        _lead = availability.leadTimeHours;
        _rules = List.of(availability.rules);
        _exceptions = List.of(availability.exceptions);
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  /// `setState` est protégé : une extension ne peut pas l'appeler, et les
  /// modifications de la semaine vivent dans un `part` pour tenir la limite
  /// de 300 lignes du projet. Elles passent donc par ce guichet.
  void _mutate(VoidCallback change) => setState(change);

  void _touch() {
    if (!_dirty) setState(() => _dirty = true);
  }

  List<AvailabilityRule> _rulesOf(int weekday) =>
      _rules.where((rule) => rule.weekday == weekday).toList();

  void _notify(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : OtherTheme.of(context).onSuccessContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: const CustomOtherAppBar(title: 'Rendez-vous'),
      body: Column(
        children: [
          Expanded(
            child: _loaded == null && _error == null
                ? const _AvailabilitySkeleton()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.appPaddingValue,
                      AppDimens.medium,
                      AppDimens.appPaddingValue,
                      AppDimens.large,
                    ),
                    children: [
                      Text(
                        widget.offer.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppDimens.spacerMini,
                      Text(
                        'Ce que vous déclarez ici est la seule chose que le '
                        'client pourra choisir.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      AppDimens.spacerLarge,

                      const _Label('Durée d\'un rendez-vous'),
                      Wrap(
                        spacing: AppDimens.small,
                        runSpacing: AppDimens.small,
                        children: [
                          for (final minutes in _durations)
                            _Chip(
                              label: _durationLabel(minutes),
                              selected: _duration == minutes,
                              onTap: () {
                                setState(() => _duration = minutes);
                                _touch();
                              },
                            ),
                        ],
                      ),
                      AppDimens.spacerLarge,

                      const _Label('Combien de clients en même temps'),
                      _Counter(
                        value: _capacity,
                        min: 1,
                        max: 200,
                        suffix: _capacity > 1 ? 'places' : 'place',
                        onChanged: (value) {
                          setState(() => _capacity = value);
                          _touch();
                        },
                      ),
                      AppDimens.spacerLarge,

                      const _Label('Délai de prévenance'),
                      _Counter(
                        value: _lead,
                        min: 0,
                        max: 72,
                        suffix: _lead > 1 ? 'heures' : 'heure',
                        onChanged: (value) {
                          setState(() => _lead = value);
                          _touch();
                        },
                      ),
                      AppDimens.spacerMini,
                      Text(
                        'En dessous de ce délai, le créneau n\'est plus '
                        'proposé.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      AppDimens.spacerLarge,

                      const _Label('Votre semaine'),
                      for (var weekday = 1; weekday <= 7; weekday++)
                        _DayBlock(
                          weekday: weekday,
                          rules: _rulesOf(weekday),
                          onToggle: (open) => _toggleDay(weekday, open),
                          onEdit: _editRange,
                          onAdd: () {
                            setState(
                              () => _rules.add(
                                AvailabilityRule(
                                  weekday: weekday,
                                  startsAt: const TimeOfDay(
                                    hour: 14,
                                    minute: 0,
                                  ),
                                  endsAt: const TimeOfDay(hour: 18, minute: 0),
                                ),
                              ),
                            );
                            _touch();
                          },
                          onRemove: (rule) {
                            setState(() => _rules.remove(rule));
                            _touch();
                          },
                        ),
                      AppDimens.spacerLarge,

                      const _Label('Fermetures exceptionnelles'),
                      for (final exception in _exceptions)
                        _ClosureRow(
                          exception: exception,
                          onRemove: () {
                            setState(() => _exceptions.remove(exception));
                            _touch();
                          },
                        ),
                      TextButton.icon(
                        onPressed: _addClosure,
                        icon: const Icon(Icons.event_busy_outlined),
                        label: const Text('Fermer une journée'),
                      ),

                      if (_loaded != null && !_dirty) ...[
                        AppDimens.spacerLarge,
                        _NextSlots(availability: _loaded!),
                      ],
                      if (_error != null) ...[
                        AppDimens.spacerMedium,
                        Text(
                          _error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          if (_dirty)
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(color: scheme.outlineVariant, width: 0.7),
                ),
              ),
              padding: const EdgeInsets.all(AppDimens.appPaddingValue),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  text: 'Enregistrer les créneaux',
                  icon: Icons.check_rounded,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _durationLabel(int minutes) {
    if (minutes >= 1440) return 'La journée';
    if (minutes % 60 == 0) return '${minutes ~/ 60} h';
    if (minutes > 60) return '${minutes ~/ 60} h ${minutes % 60}';
    return '$minutes min';
  }
}
