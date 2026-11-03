import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/password_field.dart';
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

part 'become_merchant_form_state.dart';
part 'become_merchant_form_action.dart';
part 'become_merchant_form_action_state.dart';
part 'become_merchant_form_explanation.dart';
part 'become_merchant_form_details.dart';
part 'become_merchant_form_password_step.dart';
part 'become_merchant_form_category_picker.dart';

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
