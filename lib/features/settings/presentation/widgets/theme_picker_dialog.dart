import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Affiche la boîte de dialogue de sélection du thème. Extrait de
/// settings_screen.dart pour garder ce fichier concis ; comportement
/// identique.
void showThemePickerDialog(BuildContext context) {
  final cubit = context.read<SettingsCubit>();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.scaffoldBackground,
      title: Text("Choisir le thème", style: AppFonts.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Clair"),
            trailing: cubit.state.themeMode == ThemeMode.light
                ? Icon(Icons.check, color: AppColors.secondaryLight)
                : null,
            onTap: () {
              cubit.setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Sombre"),
            trailing: cubit.state.themeMode == ThemeMode.dark
                ? Icon(Icons.check, color: AppColors.secondaryLight)
                : null,
            onTap: () {
              cubit.setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Système"),
            trailing: cubit.state.themeMode == ThemeMode.system
                ? Icon(Icons.check, color: AppColors.secondaryLight)
                : null,
            onTap: () {
              cubit.setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
