import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Demande d'ouverture d'un commerce sur Baobabe.
///
/// Les catégories proposées viennent du serveur, comme celles de l'accueil :
/// un commerçant ne doit jamais pouvoir se ranger dans une catégorie que
/// l'application ne sait pas afficher.
class BecomeMerchantPage extends StatefulWidget {
  const BecomeMerchantPage({super.key});

  @override
  State<BecomeMerchantPage> createState() => _BecomeMerchantPageState();
}

class _BecomeMerchantPageState extends State<BecomeMerchantPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();

  String? _categorySlug;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // La bande de catégories peut ne pas avoir été chargée si l'utilisateur
    // arrive ici sans passer par l'accueil.
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is! CategoriesLoaded) {
      context.read<CategoryBloc>().add(LoadCategories());
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _address, _phone, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categorySlug == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une catégorie')),
      );
      return;
    }

    setState(() => _isSending = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final error = await context.read<MerchantCubit>().apply(
      businessName: _name.text.trim(),
      categorySlug: _categorySlug!,
      address: _address.text.trim(),
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

    // Le commerce existe : on bascule directement dans l'espace commerçant
    // en remplaçant cet écran, il n'y a plus de raison d'y revenir.
    router.goNamed('merchant');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Devenir commerçant'),
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
            Text(
              'Publiez vos produits et vos services sur Baobabe. Vos clients '
              'les commandent ou les réservent depuis l\'application, et vous '
              'les gérez depuis votre espace commerçant.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            AppDimens.spacerLarge,
            _Label('Nom du commerce'),
            CustomTextFormField(
              controller: _name,
              hintText: 'Chez Mama Nzuzi',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Indiquez le nom de votre commerce'
                  : null,
            ),
            AppDimens.spacerMedium,
            _Label('Catégorie'),
            _CategoryPicker(
              selected: _categorySlug,
              onChanged: (slug) => setState(() => _categorySlug = slug),
            ),
            AppDimens.spacerMedium,
            _Label('Adresse'),
            CustomTextFormField(
              controller: _address,
              hintText: '25 avenue Kasa-Vubu, Kinshasa',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Indiquez où vous trouver'
                  : null,
            ),
            AppDimens.spacerMedium,
            _Label('Téléphone'),
            CustomTextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              hintText: '+243 …',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vos clients doivent pouvoir vous joindre'
                  : null,
            ),
            AppDimens.spacerMedium,
            _Label('Présentation (facultatif)'),
            CustomTextFormField(
              controller: _description,
              hintText: 'Ce que vous proposez, en quelques mots',
            ),
            AppDimens.spacerLarge,
            CustomButton(
              text: 'Envoyer ma demande',
              isLoading: _isSending,
              onPressed: _isSending ? () {} : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

/// Choix de la catégorie parmi celles servies par le back-end.
class _CategoryPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const _CategoryPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = state is CategoriesLoaded
            ? state.categories.where((c) => c.slug != Category.all.slug).toList()
            : const <Category>[];

        if (categories.isEmpty) {
          return Text(
            'Chargement des catégories…',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = category.slug == selected;
            return ChoiceChip(
              label: Text(category.displayName),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
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
