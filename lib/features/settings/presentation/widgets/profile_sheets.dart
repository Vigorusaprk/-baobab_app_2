import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/address_form.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profile_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ce que l'utilisateur a confirmé au moment de commander.
class DeliveryChoice {
  const DeliveryChoice({required this.address, required this.remember});

  final UserAddress address;

  /// L'utilisateur a demandé qu'on garde cette adresse pour la suite.
  final bool remember;
}

/// Demande l'adresse de livraison avant de passer la commande.
///
/// Elle s'ouvre **même si une adresse est déjà enregistrée**, pré-remplie :
/// on peut se faire livrer ailleurs qu'à son domicile, et une commande partie
/// à la mauvaise adresse sans qu'on ait demandé coûte plus cher qu'une
/// confirmation de trop.
///
/// Rend `null` si l'utilisateur referme sans confirmer.
Future<DeliveryChoice?> showDeliverySheet(BuildContext context) {
  final cubit = context.read<ProfileCubit>();
  cubit.loadProvinces();

  return showCustomBottomSheet<DeliveryChoice>(
    context: context,
    child: BlocProvider.value(value: cubit, child: const _DeliverySheet()),
  );
}

class _DeliverySheet extends StatefulWidget {
  const _DeliverySheet();

  @override
  State<_DeliverySheet> createState() => _DeliverySheetState();
}

class _DeliverySheetState extends State<_DeliverySheet> {
  late UserAddress _address =
      context.read<ProfileCubit>().state.address ?? const UserAddress();
  bool _remember = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Où vous livrer ?', style: theme.textTheme.titleLarge),
          AppDimens.spacerMini,
          Text(
            'Le commerçant en a besoin pour vous apporter votre commande.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppDimens.spacerMedium,

          AddressForm(
            initial: _address,
            provinces: state.provinces,
            onChanged: (value) => _address = value,
          ),

          CheckboxListTile(
            value: _remember,
            onChanged: (value) => setState(() => _remember = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Utiliser cette adresse pour mes prochaines commandes',
              style: theme.textTheme.bodySmall,
            ),
          ),
          AppDimens.spacerSmall,

          CustomButton(
            text: 'Confirmer la commande',
            onPressed: () {
              // Une adresse réduite à la province ne mène nulle part : on ne
              // laisse pas partir une commande qu'on ne saura pas livrer.
              if (_address.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Indiquez au moins votre commune et votre avenue.',
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(
                context,
                DeliveryChoice(address: _address, remember: _remember),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Ce que l'utilisateur a accepté de partager en réservant.
class ContactChoice {
  const ContactChoice({required this.phone, required this.remember});

  /// `null` si l'utilisateur a refusé de donner son numéro.
  final String? phone;

  final bool remember;
}

/// Demande le numéro de téléphone avant une réservation.
///
/// Une réservation ne se livre pas : il n'y a donc pas d'adresse à demander.
/// Le commerçant a en revanche besoin d'un moyen de joindre le client — pour
/// confirmer, décaler, ou prévenir. Le partage reste un **choix** : on peut
/// réserver sans laisser son numéro.
Future<ContactChoice?> showContactSheet(BuildContext context) {
  final cubit = context.read<ProfileCubit>();

  return showCustomBottomSheet<ContactChoice>(
    context: context,
    child: BlocProvider.value(value: cubit, child: const _ContactSheet()),
  );
}

class _ContactSheet extends StatefulWidget {
  const _ContactSheet();

  @override
  State<_ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends State<_ContactSheet> {
  late final TextEditingController _phone = TextEditingController(
    text: context.read<ProfileCubit>().state.profile.phone ?? '',
  );
  bool _share = true;
  bool _remember = true;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Confirmer la réservation', style: theme.textTheme.titleLarge),
        AppDimens.spacerMini,
        Text(
          'Le commerçant pourra vous joindre pour confirmer ou vous prévenir '
          "d'un changement.",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerMedium,

        CheckboxListTile(
          value: _share,
          onChanged: (value) => setState(() => _share = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Partager mon numéro de téléphone',
            style: theme.textTheme.bodySmall,
          ),
        ),

        if (_share) ...[
          AppDimens.spacerSmall,
          CustomTextFormField(
            controller: _phone,
            hintText: '+243 …',
            keyboardType: TextInputType.phone,
          ),
          CheckboxListTile(
            value: _remember,
            onChanged: (value) => setState(() => _remember = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Retenir ce numéro pour mes prochaines réservations',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],

        AppDimens.spacerSmall,
        CustomButton(
          text: 'Réserver',
          onPressed: () {
            final phone = _phone.text.trim();
            if (_share && phone.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Indiquez un numéro, ou décochez la case.'),
                ),
              );
              return;
            }
            Navigator.pop(
              context,
              ContactChoice(
                phone: _share ? phone : null,
                remember: _share && _remember,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Montre le profil dans une feuille.
///
/// Le profil était une page à part entière, atteinte depuis les paramètres.
/// Il rejoint les autres surfaces secondaires de l'application — filtres,
/// confirmation, adresse de livraison : on y jette un œil, on modifie
/// éventuellement, on referme. Une page plein écran pour ça obligeait à
/// naviguer puis à revenir.
///
/// Le contenu est **le même widget** que celui de l'ancienne page
/// ([ProfileDetails]) : les deux surfaces ne peuvent pas diverger.
Future<void> showProfileDetailsSheet(BuildContext context) {
  final cubit = context.read<ProfileCubit>()..load();

  return showCustomBottomSheet<void>(
    context: context,
    // Assez haute d'emblée pour ne pas grandir d'un coup quand les données
    // remplacent le squelette.
    minHeight: 0.72,
    child: BlocProvider.value(
      value: cubit,
      child: const ProfileDetails(title: 'Mon profil'),
    ),
  );
}

/// Le formulaire de profil : identité et adresse, dans une seule feuille.
///
/// C'est la **même** feuille pour « Compléter mon profil » et « Modifier le
/// profil » — c'est le même geste, et deux formulaires auraient divergé.
/// Elle remplace l'ancienne page `/edit-profile`, qui ne savait rien
/// enregistrer.
Future<bool> showProfileSheet(BuildContext context) async {
  final cubit = context.read<ProfileCubit>();
  cubit.loadProvinces();

  final saved = await showCustomBottomSheet<bool>(
    context: context,
    child: BlocProvider.value(value: cubit, child: const _ProfileSheet()),
  );
  return saved ?? false;
}

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet();

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late final ProfileState _initial = context.read<ProfileCubit>().state;
  late final TextEditingController _name = TextEditingController(
    text: _initial.profile.name ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: _initial.profile.phone ?? '',
  );
  late UserAddress _address = _initial.address ?? const UserAddress();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Mes informations', style: theme.textTheme.titleLarge),
          AppDimens.spacerMini,
          Text(
            'Elles servent à vous livrer et à vous joindre.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppDimens.spacerMedium,

          CustomTextFormField(
            label: 'Nom complet',
            controller: _name,
            hintText: 'Votre nom',
            textCapitalization: TextCapitalization.words,
          ),
          AppDimens.spacerMedium,
          CustomTextFormField(
            label: 'Téléphone',
            controller: _phone,
            hintText: '+243 …',
            keyboardType: TextInputType.phone,
          ),
          AppDimens.spacerLarge,

          Text('Adresse', style: theme.textTheme.titleSmall),
          AppDimens.spacerSmall,
          AddressForm(
            initial: _address,
            provinces: state.provinces,
            onChanged: (value) => _address = value,
          ),

          if (state.message != null) ...[
            Text(
              state.message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            AppDimens.spacerSmall,
          ],

          // L'état de chargement vient du bouton partagé : il montre son
          // indicateur plutôt que de changer son libellé en
          // « Enregistrement… », qui se lisait comme un autre bouton.
          CustomButton(
            text: 'Enregistrer',
            isLoading: state.saving,
            onPressed: () async {
              final cubit = context.read<ProfileCubit>();
              final ok = await cubit.save(
                name: _name.text.trim(),
                phone: _phone.text.trim(),
                address: _address,
              );
              if (!context.mounted || !ok) return;
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }
}
