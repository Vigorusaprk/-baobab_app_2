part of 'become_merchant_sheet.dart';

/// Les champs du commerce : identité, catégorie, adresse, présentation.
///
/// Le **même** formulaire d'adresse que la feuille de livraison, et les mêmes
/// colonnes en base : province, ville, commune, quartier, avenue, numéro.
/// Une ligne de texte libre interdisait de lister les commerces d'une
/// commune.
class _MerchantDetails extends StatelessWidget {
  const _MerchantDetails({
    required this.name,
    required this.phone,
    required this.description,
    required this.categorySlug,
    required this.onCategoryChanged,
    required this.address,
    required this.onAddressChanged,
  });

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController description;
  final String? categorySlug;
  final ValueChanged<String> onCategoryChanged;
  final UserAddress address;
  final ValueChanged<UserAddress> onAddressChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          label: 'Nom du commerce',
          controller: name,
          hintText: 'Chez Mama Nzuzi',
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Indiquez le nom de votre commerce' : null,
        ),
        AppDimens.spacerMedium,

        Text(
          'Catégorie',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerMini,
        _CategoryPicker(
          selected: categorySlug,
          onChanged: onCategoryChanged,
        ),
        AppDimens.spacerMedium,

        CustomTextFormField(
          label: 'Téléphone',
          controller: phone,
          keyboardType: TextInputType.phone,
          hintText: '+243 …',
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Vos clients doivent pouvoir vous joindre'
              : null,
        ),
        AppDimens.spacerMedium,

        Text(
          'Adresse',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimens.spacerSmall,
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => AddressForm(
            initial: address,
            provinces: state.provinces,
            onChanged: onAddressChanged,
          ),
        ),
        AppDimens.spacerMedium,

        CustomTextFormField(
          label: 'Présentation (facultatif)',
          controller: description,
          hintText: 'Ce que vous proposez, en quelques mots',
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
