import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Affiche la boîte de dialogue de sélection de la langue. Extrait de
/// settings_screen.dart pour garder ce fichier concis ; comportement
/// identique.
void showLanguagePickerDialog(BuildContext context) {
  final cubit = context.read<SettingsCubit>();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.background,
      title: Text("Choisir la langue", style: AppFonts.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Français"),
            trailing: cubit.state.locale.languageCode == 'fr'
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              cubit.setLocale(const Locale('fr', 'FR'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("English"),
            trailing: cubit.state.locale.languageCode == 'en'
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              cubit.setLocale(const Locale('en', 'US'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Lingala"),
            trailing: cubit.state.locale.languageCode == 'ln'
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              cubit.setLocale(const Locale('ln', 'CD'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
