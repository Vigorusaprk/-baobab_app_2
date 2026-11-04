import 'package:baobabe_0_2/features/settings/presentation/cubit/security_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// La section « Sécurité » des paramètres.
///
/// Le libellé suit l'état réel du compte : un utilisateur sans mot de passe
/// doit en poser un avant d'utiliser Baobab Business ; on ne lui propose pas
/// « Changer » sans qu'il en ait un.
class SecuritySettingsSection extends StatelessWidget {
  const SecuritySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecurityCubit, SecurityState>(
      builder: (context, state) {
        return DetailSection(
          sectionTitle: 'Sécurité',
          children: [
            InfoTile(
              subtitle: state.hasPassword
                  ? 'Changer mon mot de passe'
                  : 'Définir un mot de passe',
              icon: Icons.lock_outline,
              onTap: () => context.push('/settings/security'),
            ),
          ],
        );
      },
    );
  }
}
