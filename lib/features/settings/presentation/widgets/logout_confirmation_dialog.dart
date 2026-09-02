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
///
/// **On attend que la session soit réellement fermée avant de naviguer.**
/// Le code d'avant faisait ceci :
///
/// ```dart
/// context.read<AuthBloc>().add(SignOutEvent());
/// context.go('/login');
/// ```
///
/// `add` ne fait qu'empiler l'événement : au moment du `go`, la session était
/// toujours valide, et la garde du routeur — « connecté sur une route
/// d'authentification ? alors `/home` » — renvoyait donc à l'accueil. La
/// déconnexion aboutissait bien, mais en arrière-plan et sans que l'écran le
/// montre ; il fallait recommencer pour que la garde laisse enfin passer.
/// D'où deux déconnexions pour une.
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

  final bloc = context.read<AuthBloc>();
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);

  // L'écoute est posée **avant** l'événement : dans l'autre ordre, une
  // déconnexion instantanée pourrait être émise avant qu'on écoute, et
  // l'attente ne se dénouerait jamais.
  final settled = bloc.stream.firstWhere(
    (state) => state is SignOutSuccess || state is SignOutFailure,
  );
  bloc.add(SignOutEvent());
  final outcome = await settled;

  if (outcome is SignOutFailure) {
    // Rester sur place est la bonne réponse : on n'a pas quitté la session,
    // il ne faut donc pas faire croire qu'on l'a quittée.
    messenger.showSnackBar(SnackBar(content: Text(outcome.error)));
    return;
  }

  router.go('/login');
}
