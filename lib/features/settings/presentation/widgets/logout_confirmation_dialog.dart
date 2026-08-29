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
      title: Text(
        "Déconnexion",
        style: Theme.of(context).textTheme.titleMedium!,
      ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text("Se déconnecter"),
        ),
      ],
    ),
  );
}
