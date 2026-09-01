import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:flutter/material.dart';

/// Le formulaire d'adresse, groupé par paliers géographiques.
///
/// Six champs empilés se lisent comme une corvée. Ils sont donc appariés du
/// large au précis — province avec ville, commune avec quartier, avenue avec
/// numéro — ce qui donne trois lignes au lieu de six et fait apparaître la
/// logique de l'adresse dans sa forme même.
///
/// Le numéro est nettement plus étroit que l'avenue : il porte « 10F », pas un
/// nom de rue. Sur un écran trop étroit pour tenir une paire, chaque champ
/// retombe sous son voisin plutôt que de se comprimer.
///
/// Province et ville se **tapent ou se choisissent** : la liste vient du
/// serveur, mais quelqu'un qui habite un lieu absent du référentiel doit
/// pouvoir l'écrire.
class AddressForm extends StatefulWidget {
  const AddressForm({
    super.key,
    required this.initial,
    required this.provinces,
    required this.onChanged,
  });

  final UserAddress initial;
  final List<Province> provinces;
  final ValueChanged<UserAddress> onChanged;

  /// En dessous, une paire ne tient plus côte à côte.
  static const double _pairBreakpoint = 260;

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  late final TextEditingController _province;
  late final TextEditingController _ville;
  late final TextEditingController _commune;
  late final TextEditingController _quartier;
  late final TextEditingController _avenue;
  late final TextEditingController _numero;

  @override
  void initState() {
    super.initState();
    _province = TextEditingController(text: widget.initial.province);
    _ville = TextEditingController(text: widget.initial.ville ?? '');
    _commune = TextEditingController(text: widget.initial.commune ?? '');
    _quartier = TextEditingController(text: widget.initial.quartier ?? '');
    _avenue = TextEditingController(text: widget.initial.avenue ?? '');
    _numero = TextEditingController(text: widget.initial.numero ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _province,
      _ville,
      _commune,
      _quartier,
      _avenue,
      _numero,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Les villes de la province saisie. Une province inconnue du référentiel
  /// n'en propose aucune — le champ reste libre.
  List<String> get _citiesOfProvince {
    final name = _province.text.trim().toLowerCase();
    for (final p in widget.provinces) {
      if (p.name.toLowerCase() == name) return p.cities;
    }
    return const [];
  }

  void _emit() {
    String? clean(TextEditingController c) {
      final text = c.text.trim();
      return text.isEmpty ? null : text;
    }

    widget.onChanged(
      UserAddress(
        province: clean(_province) ?? UserAddress.defaultProvince,
        ville: clean(_ville),
        commune: clean(_commune),
        quartier: clean(_quartier),
        avenue: clean(_avenue),
        numero: clean(_numero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Pair(
          left: _Suggesting(
            label: 'Province',
            controller: _province,
            options: widget.provinces.map((p) => p.name).toList(),
            onChanged: (_) {
              // Changer de province invalide la ville : Goma n'est pas au
              // Kongo-Central.
              if (!_citiesOfProvince.contains(_ville.text.trim())) {
                _ville.clear();
              }
              setState(_emit);
            },
          ),
          right: _Suggesting(
            label: 'Ville',
            controller: _ville,
            options: _citiesOfProvince,
            onChanged: (_) => _emit(),
          ),
        ),
        _Pair(
          left: _Plain(
            label: 'Commune',
            controller: _commune,
            onChanged: (_) => _emit(),
          ),
          right: _Plain(
            label: 'Quartier',
            controller: _quartier,
            onChanged: (_) => _emit(),
          ),
        ),
        _Pair(
          // L'avenue porte un nom, le numéro deux ou trois caractères.
          leftFlex: 3,
          rightFlex: 2,
          left: _Plain(
            label: 'Avenue',
            controller: _avenue,
            onChanged: (_) => _emit(),
          ),
          right: _Plain(
            label: 'N°',
            controller: _numero,
            hint: '10F',
            onChanged: (_) => _emit(),
          ),
        ),
      ],
    );
  }
}

/// Deux champs côte à côte, qui se remettent l'un sous l'autre si la place
/// manque.
class _Pair extends StatelessWidget {
  const _Pair({
    required this.left,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.medium),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < AddressForm._pairBreakpoint) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                left,
                const SizedBox(height: AppDimens.medium),
                right,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: leftFlex, child: left),
              const SizedBox(width: AppDimens.small),
              Expanded(flex: rightFlex, child: right),
            ],
          );
        },
      ),
    );
  }
}

/// Un champ libre, avec son étiquette au-dessus.
class _Plain extends StatelessWidget {
  const _Plain({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return _Labelled(
      label: label,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.words,
        style: Theme.of(context).textTheme.bodySmall,
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }
}

/// Un champ qui propose une liste, sans l'imposer.
class _Suggesting extends StatelessWidget {
  const _Suggesting({
    required this.label,
    required this.controller,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Labelled(
      label: label,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.words,
        style: Theme.of(context).textTheme.bodySmall,
        decoration: InputDecoration(
          // Le menu n'apparaît que s'il y a quelque chose à proposer : une
          // flèche qui n'ouvre rien est un contrôle décoratif.
          suffixIcon: options.isEmpty
              ? null
              : PopupMenuButton<String>(
                  tooltip: 'Choisir $label',
                  icon: Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    controller.text = value;
                    onChanged(value);
                  },
                  itemBuilder: (context) => [
                    for (final option in options)
                      PopupMenuItem(value: option, child: Text(option)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
