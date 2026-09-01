import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Le profil de l'utilisateur.
///
/// L'adresse s'y lit **sur une seule ligne**, du précis au large, comme on la
/// dit à voix haute. Elle est pourtant stockée en six colonnes : ce n'est pas
/// une contradiction, c'est la différence entre ce qu'on range et ce qu'on
/// montre.
///
/// Tant que les informations manquent, la page propose de les compléter plutôt
/// que d'aligner des « Non renseigné ». Le formulaire est le même dans les
/// deux cas — compléter et modifier sont le même geste.
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomOtherAppBar(title: 'Mon profil'),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.failure) {
            return _Failure(
              message: state.message ?? 'Réessayez dans un instant.',
              onRetry: () => context.read<ProfileCubit>().load(force: true),
            );
          }
          if (state.status != ProfileStatus.ready) {
            return const Skeletonizer(enabled: true, child: _Skeleton());
          }
          return _Body(state: state);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = state.address;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.large),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              _initial(state.profile.name),
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          AppDimens.spacerLarge,

          _Line(
            label: 'Nom complet',
            value: state.profile.name,
            icon: Icons.badge_outlined,
          ),
          _Line(
            label: 'Adresse e-mail',
            value: state.profile.email,
            icon: Icons.email_outlined,
            // L'e-mail vient du compte : il ne se modifie pas ici.
            editable: false,
          ),
          _Line(
            label: 'Téléphone',
            value: state.profile.phone,
            icon: Icons.phone_android_outlined,
          ),
          _Line(
            label: 'Adresse',
            // Six colonnes, une seule ligne à l'écran.
            value: (address == null || address.isEmpty)
                ? null
                : address.oneLine,
            icon: Icons.location_on_outlined,
          ),

          AppDimens.spacerLarge,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final saved = await showProfileSheet(context);
                if (!context.mounted || !saved) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Informations enregistrées.')),
                );
              },
              icon: Icon(
                state.isIncomplete ? Icons.add_rounded : Icons.edit_outlined,
              ),
              label: Text(
                // Le libellé dit l'état de la fiche : proposer « Modifier »
                // sur un profil vide n'a pas de sens.
                state.isIncomplete
                    ? 'Compléter mon profil'
                    : 'Modifier mon profil',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppDimens.medium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initial(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }
}

/// Une information du profil. Quand elle manque, elle le dit en clair plutôt
/// que d'afficher un vide qu'on pourrait prendre pour un bug.
class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    required this.icon,
    this.editable = true,
  });

  final String label;
  final String? value;
  final IconData icon;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final missing = value == null || value!.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.medium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppDimens.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  missing
                      ? (editable ? 'À compléter' : 'Non renseignée')
                      : value!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: missing
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                    fontStyle: missing ? FontStyle.italic : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Squelette de la page, calqué sur [_Body].
///
/// Il empilait auparavant quatre courtes barres centrées : rien à voir avec
/// la page réelle, qui aligne une icône puis deux lignes de texte sur toute
/// la largeur. Le résultat paraissait tassé au milieu, puis sautait
/// entièrement à l'arrivée des données.
///
/// Les largeurs des valeurs sont volontairement inégales — un nom est court,
/// une adresse est longue. Des barres toutes identiques se lisent comme un
/// gabarit, pas comme du contenu qui arrive.
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  /// Longueur approximative de chaque valeur, dans l'ordre de [_Body].
  static const List<double> _valueWidths = [140, 210, 130, 250];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Bone.circle(size: 100)),
          AppDimens.spacerLarge,

          for (final width in _valueWidths)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.medium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Bone.square(size: 20),
                  const SizedBox(width: AppDimens.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bone.text(
                          width: 90,
                          style: theme.textTheme.labelSmall!,
                        ),
                        const SizedBox(height: 2),
                        Bone.text(
                          width: width,
                          style: theme.textTheme.bodySmall!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          AppDimens.spacerLarge,
          // Le bouton occupe toute la largeur : le squelette aussi, sans quoi
          // le bas de la page se décale au moment du chargement.
          Bone(
            width: double.infinity,
            height: AppDimens.touchTarget,
            borderRadius: BorderRadius.circular(AppDimens.radius16),
          ),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            AppDimens.spacerMedium,
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
