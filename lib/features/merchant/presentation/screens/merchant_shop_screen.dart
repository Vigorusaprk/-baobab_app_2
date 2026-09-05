import 'package:baobabe_0_2/core/services/media_upload_service.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:baobabe_0_2/core/widgets/image_upload_field.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/opening_hours_editor.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/address_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// La fiche du commerce, tenue par son commerçant.
///
/// Rien de tout cela n'était modifiable après l'ouverture du compte : un
/// numéro faux le restait, un horaire changé n'était jamais répercuté, et une
/// fermeture pour congés obligeait à retirer les offres une par une.
///
/// **La catégorie n'y est pas.** Elle décide du classement et des filtres de
/// toute la plateforme : un commerce qui se reclasse lui-même apparaîtrait là
/// où personne ne l'attend, sans arbitrage.
///
/// L'écran ne s'enregistre pas tout seul : le bouton n'apparaît que lorsque
/// quelque chose a changé, et il dit ce qu'il fait.
class MerchantShopScreen extends StatefulWidget {
  const MerchantShopScreen({super.key, required this.space});

  final MerchantSpace space;

  @override
  State<MerchantShopScreen> createState() => _MerchantShopScreenState();
}

class _MerchantShopScreenState extends State<MerchantShopScreen> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _website;

  late String? _cover;
  late Map<String, String> _hours;
  late UserAddress _address;
  late bool _paused;

  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final business = widget.space.business;
    _name = TextEditingController(text: business?.name ?? '');
    _description = TextEditingController(text: business?.description ?? '');
    _phone = TextEditingController(text: business?.phone ?? '');
    _email = TextEditingController(text: business?.email ?? '');
    _website = TextEditingController(text: business?.website ?? '');
    _cover = business?.bgImg;
    _hours = Map<String, String>.from(business?.openingHours ?? const {});
    _paused = business?.isPaused ?? false;
    _address = UserAddress(
      province: business?.province ?? UserAddress.defaultProvince,
      ville: business?.ville,
      commune: business?.commune,
      quartier: business?.quartier,
      avenue: business?.avenue,
      numero: business?.numero,
    );

    // Les provinces viennent du serveur : ajouter une ville ne demande pas de
    // publier une version.
    context.read<ProfileCubit>().loadProvinces();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    super.dispose();
  }

  void _touch() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.length < 2) {
      _notify('Le nom du commerce est obligatoire.', isError: true);
      return;
    }

    setState(() => _saving = true);
    final error = await context.read<MerchantCubit>().updateBusiness(
      BusinessDraft(
        name: name,
        description: _description.text.trim(),
        coverImage: _cover,
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        website: _website.text.trim(),
        openingHours: _hours,
        address: _address,
        isPaused: _paused,
      ),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _dirty = error != null;
    });
    _notify(
      error ?? 'Votre fiche est à jour.',
      isError: error != null,
    );
  }

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
    final business = widget.space.business;
    if (business == null) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.appPaddingValue,
              AppDimens.medium,
              AppDimens.appPaddingValue,
              AppDimens.large,
            ),
            children: [
              _AdsEntry(space: widget.space),
              AppDimens.spacerLarge,

              ImageUploadField(
                businessId: business.id,
                kind: MediaKind.cover,
                value: _cover,
                label: 'Photo de couverture',
                hint: "C'est la première chose qu'un client voit de vous.",
                onChanged: (url) {
                  setState(() => _cover = url);
                  _touch();
                },
              ),
              AppDimens.spacerLarge,

              const _SectionTitle('Identité'),
              CustomTextFormField(
                controller: _name,
                label: 'Nom du commerce',
                hintText: 'Le Grill du Boulevard',
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => _touch(),
              ),
              AppDimens.spacerSmall,
              CustomTextFormField(
                controller: _description,
                label: 'Description',
                hintText: 'Ce que vous faites, en deux phrases.',
                maxLines: 4,
                onChanged: (_) => _touch(),
              ),
              AppDimens.spacerSmall,
              _CategoryLine(label: business.type.name),
              AppDimens.spacerLarge,

              const _SectionTitle('Contact'),
              CustomTextFormField(
                controller: _phone,
                label: 'Téléphone',
                hintText: '+243 900 000 000',
                keyboardType: TextInputType.phone,
                onChanged: (_) => _touch(),
              ),
              AppDimens.spacerSmall,
              CustomTextFormField(
                controller: _email,
                label: 'Courriel',
                hintText: 'contact@moncommerce.cd',
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _touch(),
              ),
              AppDimens.spacerSmall,
              CustomTextFormField(
                controller: _website,
                label: 'Site web',
                hintText: 'https://…',
                keyboardType: TextInputType.url,
                onChanged: (_) => _touch(),
              ),
              AppDimens.spacerLarge,

              const _SectionTitle('Adresse'),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) => AddressForm(
                  initial: _address,
                  provinces: state.provinces,
                  onChanged: (address) {
                    _address = address;
                    _touch();
                  },
                ),
              ),
              AppDimens.spacerLarge,

              const _SectionTitle('Horaires'),
              OpeningHoursEditor(
                value: _hours,
                onChanged: (hours) {
                  setState(() => _hours = hours);
                  _touch();
                },
              ),
              AppDimens.spacerLarge,

              const _SectionTitle('Disponibilité'),
              _PauseTile(
                paused: _paused,
                onChanged: (paused) {
                  setState(() => _paused = paused);
                  _touch();
                },
              ),
              AppDimens.spacerLarge,

              TextButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Voir ma fiche comme un client'),
              ),
            ],
          ),
        ),
        // Le bouton n'apparaît que s'il y a quelque chose à enregistrer : un
        // bouton toujours présent laisse croire qu'on a oublié de l'utiliser.
        if (_dirty)
          _SaveBar(
            saving: _saving,
            onSave: _save,
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.small),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// La catégorie, montrée mais pas modifiable : elle décide du classement de
/// toute la plateforme.
class _CategoryLine extends StatelessWidget {
  const _CategoryLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: AppDimens.medium,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        AppDimens.spacerSmallWidth,
        Expanded(
          child: Text(
            'Catégorie : $label. Écrivez-nous pour en changer.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// La fermeture temporaire.
class _PauseTile extends StatelessWidget {
  const _PauseTile({required this.paused, required this.onChanged});

  final bool paused;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final other = OtherTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.medium),
      decoration: BoxDecoration(
        color: paused
            ? other.warningContainer
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fermé temporairement',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: paused ? other.onWarningContainer : null,
                  ),
                ),
                AppDimens.spacerMini,
                Text(
                  paused
                      ? 'Votre commerce et vos offres sont retirés de la '
                            'découverte. Rien n\'est supprimé.'
                      : 'Congés, travaux : retirez tout de la découverte '
                            'sans rien supprimer.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: paused
                        ? other.onWarningContainer
                        : theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          AppDimens.spacerMediumWidth,
          Switch(value: paused, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
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
          text: 'Enregistrer',
          icon: Icons.check_rounded,
          isLoading: saving,
          onPressed: onSave,
        ),
      ),
    );
  }
}

/// L'entrée vers la publicité : un commerçant ne devine pas qu'elle existe.
class _AdsEntry extends StatelessWidget {
  const _AdsEntry({required this.space});

  final MerchantSpace space;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final running = space.stats.runningCampaigns;
    final open = space.openCampaigns.length;

    return MerchantCard(
      onTap: () => context.push('/merchant/ads'),
      child: Row(
        children: [
          Icon(Icons.campaign_outlined, color: scheme.primary),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mise en avant',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppDimens.spacerMini,
                Text(
                  running > 0
                      ? '$running campagne${running > 1 ? 's' : ''} en '
                            'diffusion'
                      : open > 0
                      ? '$open demande${open > 1 ? 's' : ''} en cours'
                      : 'Apparaissez en tête de l\'accueil.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
