import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/offer_form_fields.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Publication ou modification d'une offre.
///
/// Un seul formulaire pour les trois cas de figure : ce qui distingue un
/// plat d'une séance de spa n'est pas sa nature mais la case cochée ici —
/// se commande, se réserve, ou se trouve simplement en boutique. Les champs
/// propres à la réservation (nombre de places, date) n'apparaissent que
/// dans ce second cas.
class OfferFormPage extends StatefulWidget {
  /// Offre existante à modifier, ou `null` pour une publication.
  final Offer? offer;

  const OfferFormPage({super.key, this.offer});

  @override
  State<OfferFormPage> createState() => _OfferFormPageState();
}

class _OfferFormPageState extends State<OfferFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _section;
  late final TextEditingController _capacity;
  late final TextEditingController _imageUrl;

  late Fulfilment _fulfilment;
  DateTime? _startsAt;
  bool _isSaving = false;

  bool get _isEditing => widget.offer != null;

  @override
  void initState() {
    super.initState();
    final offer = widget.offer;
    _name = TextEditingController(text: offer?.name ?? '');
    _description = TextEditingController(text: offer?.description ?? '');
    _price = TextEditingController(
      text: offer == null || offer.price == 0
          ? ''
          : offer.price.toStringAsFixed(2),
    );
    _section = TextEditingController(text: offer?.section ?? '');
    _capacity = TextEditingController(text: offer?.capacity?.toString() ?? '');
    _imageUrl = TextEditingController(text: offer?.imageUrl ?? '');
    _fulfilment = offer?.fulfilment ?? Fulfilment.order;
    _startsAt = offer?.startsAt;
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _description,
      _price,
      _section,
      _capacity,
      _imageUrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Ce que le choix implique pour le commerçant, dit une fois plutôt que
  /// laissé à deviner : « en boutique » n'ouvre aucune transaction dans
  /// l'application.
  String get _fulfilmentHint {
    switch (_fulfilment) {
      case Fulfilment.order:
        return "Vos clients la commandent depuis l'application et vous "
            'recevez la commande à préparer.';
      case Fulfilment.booking:
        return 'Vos clients réservent une place ou un créneau, que vous '
            'confirmez ensuite.';
      case Fulfilment.inStore:
        return "L'offre est visible dans l'application mais ne se commande "
            'ni ne se réserve : vos clients viennent la chercher sur place.';
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt ?? now),
    );
    if (!mounted) return;

    setState(() {
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    final cubit = context.read<MerchantCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final draft = OfferDraft(
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.tryParse(_price.text.trim().replaceAll(',', '.')) ?? 0,
      fulfilment: _fulfilment,
      section: _section.text.trim().isEmpty ? null : _section.text.trim(),
      capacity: _fulfilment == Fulfilment.booking
          ? int.tryParse(_capacity.text.trim())
          : null,
      startsAt: _fulfilment == Fulfilment.booking ? _startsAt : null,
      imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
    );

    final error = _isEditing
        ? await cubit.updateOffer(widget.offer!.id, draft)
        : await cubit.createOffer(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          error ?? (_isEditing ? 'Offre mise à jour' : 'Offre publiée'),
        ),
      ),
    );
    if (error == null) router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isBooking = _fulfilment == Fulfilment.booking;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomOtherAppBar(
        title: _isEditing ? "Modifier l'offre" : 'Nouvelle offre',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.appPaddingValue,
            0,
            AppDimens.appPaddingValue,
            40,
          ),
          children: [
            FieldLabel('Comment vos clients l\'obtiennent'),
            SegmentedButton<Fulfilment>(
              // Libellés courts : trois segments doivent tenir sur une
              // ligne, même sur un petit écran.
              segments: const [
                ButtonSegment(
                  value: Fulfilment.order,
                  label: Text('Commande'),
                  icon: Icon(Icons.shopping_bag_outlined),
                ),
                ButtonSegment(
                  value: Fulfilment.booking,
                  label: Text('Réservation'),
                  icon: Icon(Icons.event_available_outlined),
                ),
                ButtonSegment(
                  value: Fulfilment.inStore,
                  label: Text('En boutique'),
                  icon: Icon(Icons.storefront_outlined),
                ),
              ],
              showSelectedIcon: false,
              selected: {_fulfilment},
              onSelectionChanged: (value) =>
                  setState(() => _fulfilment = value.first),
            ),
            AppDimens.spacerSmall,
            FieldHint(_fulfilmentHint),
            AppDimens.spacerMedium,
            FieldLabel('Nom'),
            CustomTextFormField(
              controller: _name,
              hintText: isBooking ? 'Séance de massage' : 'Poulet moambe',
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Donnez un nom à votre offre'
                  : null,
            ),
            AppDimens.spacerMedium,
            FieldLabel('Description'),
            CustomTextFormField(
              controller: _description,
              hintText: 'Ce que le client reçoit exactement',
            ),
            AppDimens.spacerMedium,
            FieldLabel('Prix en dollars'),
            CustomTextFormField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hintText: '0 pour « sur demande »',
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final parsed = double.tryParse(
                  value.trim().replaceAll(',', '.'),
                );
                if (parsed == null) return 'Entrez un montant valide';
                if (parsed < 0) return 'Le prix ne peut pas être négatif';
                return null;
              },
            ),
            AppDimens.spacerMedium,
            FieldLabel('Rayon ou rubrique (facultatif)'),
            CustomTextFormField(
              controller: _section,
              hintText: isBooking ? 'Soins du visage' : 'Plats',
            ),
            if (isBooking) ...[
              AppDimens.spacerMedium,
              FieldLabel('Places disponibles (facultatif)'),
              CustomTextFormField(
                controller: _capacity,
                keyboardType: TextInputType.number,
                hintText: 'Laissez vide si illimité',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Entrez un nombre de places valide';
                  }
                  return null;
                },
              ),
              AppDimens.spacerMedium,
              FieldLabel('Date imposée (facultatif)'),
              DateField(
                value: _startsAt,
                onPick: _pickDate,
                onClear: () => setState(() => _startsAt = null),
              ),
            ],
            AppDimens.spacerMedium,
            FieldLabel('Lien de la photo (facultatif)'),
            CustomTextFormField(controller: _imageUrl, hintText: 'https://…'),
            AppDimens.spacerLarge,
            CustomButton(
              text: _isEditing ? 'Enregistrer' : 'Publier l\'offre',
              isLoading: _isSaving,
              onPressed: _isSaving ? () {} : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
