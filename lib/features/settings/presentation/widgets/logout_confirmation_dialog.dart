import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Affiche la boîte de dialogue de confirmation de déconnexion. Extrait de
/// settings_screen.dart pour garder ce fichier concis ; comportement
/// identique (l'appel à AuthBloc/SignOutEvent est inchangé).
void showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Déconnexion", style: AppFonts.titleMedium),
      content: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AuthBloc>().add(SignOutEvent());
            context.go('/login');
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorContent),
          child: Text("Se déconnecter"),
        ),
      ],
    ),
  );
}
