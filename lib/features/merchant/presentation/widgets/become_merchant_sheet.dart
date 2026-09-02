import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/notification/domain/notification_reason.dart';
import 'package:baobabe_0_2/features/notification/presentation/notification_prompt.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/address_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ouvre la demande d'ouverture de commerce.
///
/// C'était une page pleine, avec son app bar et son paragraphe d'explication
/// en tête. Elle est devenue une feuille, comme tout ce qui se remplit en une
/// fois dans l'application, et le paragraphe s'est effacé derrière un bouton
/// d'information : il rassure la première fois et encombre les suivantes.
///
/// Renvoie `true` si le commerce a été créé.
Future<bool> showBecomeMerchantSheet(BuildContext context) async {
  final merchant = context.read<MerchantCubit>();
  final categories = context.read<CategoryBloc>();
  final profile = context.read<ProfileCubit>();

  // Les provinces viennent du serveur, comme pour l'adresse de livraison :
  // ajouter une ville ne demande pas de publier une version.
  profile.loadProvinces();
  if (categories.state is! CategoriesLoaded) {
    categories.add(LoadCategories());
  }

  final created = await showCustomBottomSheet<bool>(
    context: context,
    title: 'Devenir commerçant',
    child: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: merchant),
        BlocProvider.value(value: categories),
        BlocProvider.value(value: profile),
      ],
      child: const _BecomeMerchantForm(),
    ),
  );
  return created ?? false;
}

class _BecomeMerchantForm extends StatefulWidget {
  const _BecomeMerchantForm();

  @override
  State<_BecomeMerchantForm> createState() => _BecomeMerchantFormState();
}

class _BecomeMerchantFormState extends State<_BecomeMerchantForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();

  String? _categorySlug;
  UserAddress _address = const UserAddress();
  bool _isSending = false;
  bool _showExplanation = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final messenger = ScaffoldMessenger.of(context);
    if (_categorySlug == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Choisissez une catégorie')),
      );
      return;
    }
    // Même exigence que la feuille de livraison, et que la base : une adresse
    // réduite à la province ne permet pas de trouver le commerce.
    if (_address.commune == null || _address.avenue == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Indiquez au moins votre commune et votre avenue.'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    final error = await context.read<MerchantCubit>().apply(
      businessName: _name.text.trim(),
      categorySlug: _categorySlug!,
      address: _address,
      phone: _phone.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSending = false);

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // Un commerçant qui n'est pas prévenu doit garder l'application ouverte
    // pour ne pas manquer une commande. C'est la raison la plus forte de
    // toutes, et le bon moment pour la donner.
    await NotificationPrompt.maybeAsk(
      context,
      NotificationReason.merchantJoined,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // L'explication, derrière un bouton. Elle occupait le haut de
          // l'écran à chaque visite alors qu'on ne la lit qu'une fois.
          Align(
            alignment: Alignment.centerRight,
            child: CustomIconButton(
              onPressed: () =>
                  setState(() => _showExplanation = !_showExplanation),
              tooltip: _showExplanation
                  ? 'Masquer l\'explication'
                  : 'À quoi sert un compte commerçant ?',
              icon: _showExplanation
                  ? Icons.info_rounded
                  : Icons.info_outline_rounded,
              tone: IconButtonTone.ghost,
              iconSize: AppDimens.large,
            ),
          ),
          AnimatedSize(
            duration: AppMotion.duration(context, AppMotion.base),
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: _showExplanation
                ? Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.medium),
                    child: Text(
                      'Publiez vos produits et vos services sur Baobabe. Vos '
                      'clients les commandent ou les réservent depuis '
                      'l\'application, et vous les gérez depuis votre espace '
                      'commerçant.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          CustomTextFormField(
            label: 'Nom du commerce',
            controller: _name,
            hintText: 'Chez Mama Nzuzi',
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Indiquez le nom de votre commerce'
                : null,
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
            selected: _categorySlug,
            onChanged: (slug) => setState(() => _categorySlug = slug),
          ),
          AppDimens.spacerMedium,

          CustomTextFormField(
            label: 'Téléphone',
            controller: _phone,
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
          // Le **même** formulaire que l'adresse de livraison, et les mêmes
          // colonnes en base : province, ville, commune, quartier, avenue,
          // numéro. Une ligne de texte libre interdisait de lister les
          // commerces d'une commune.
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) => AddressForm(
              initial: _address,
              provinces: state.provinces,
              onChanged: (address) => _address = address,
            ),
          ),
          AppDimens.spacerMedium,

          CustomTextFormField(
            label: 'Présentation (facultatif)',
            controller: _description,
            hintText: 'Ce que vous proposez, en quelques mots',
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          AppDimens.spacerLarge,

          CustomButton(
            text: 'Envoyer ma demande',
            isLoading: _isSending,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// Les catégories proposées viennent du serveur, comme celles de l'accueil :
/// un commerçant ne doit jamais pouvoir se ranger dans une catégorie que
/// l'application ne sait pas afficher.
///
/// Repris tel quel de l'ancienne page : même apparence, à l'identique.
class _CategoryPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const _CategoryPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = state is CategoriesLoaded
            ? state.categories
                  .where((c) => c.slug != Category.all.slug)
                  .toList()
            : const <Category>[];

        if (categories.isEmpty) {
          return Text(
            'Chargement des catégories…',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }

        return Wrap(
          spacing: AppDimens.small,
          runSpacing: AppDimens.small,
          children: categories.map((category) {
            final isSelected = category.slug == selected;
            return ChoiceChip(
              label: Text(category.displayName),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              onSelected: (_) => onChanged(category.slug),
            );
          }).toList(),
        );
      },
    );
  }
}
