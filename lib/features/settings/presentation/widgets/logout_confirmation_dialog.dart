import 'package:baobabe_0_2/core/widgets/custom_pop_up.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Demande confirmation avant de fermer la session.
///
/// La fenêtre elle-même vient de [CustomPopUp] : elle ne décide plus de son
/// apparence, seulement de ce qui se passe quand on dit oui. La déconnexion
/// est traitée comme destructrice — elle ne détruit pas de données, mais elle
/// coupe l'accès aux commandes et réservations en cours, et se répare en
/// retapant un mot de passe.
Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  final confirmed = await showCustomPopUp(
    context: context,
    title: 'Voulez-vous vraiment vous déconnecter ?',
    message:
        'Vous devrez vous reconnecter pour retrouver vos commandes et '
        'vos réservations. À bientôt !',
    icon: Icons.logout_rounded,
  );
  if (!confirmed || !context.mounted) return;

  context.read<AuthBloc>().add(SignOutEvent());
  context.go('/login');
}
