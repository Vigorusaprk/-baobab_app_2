part of 'settings_screen.dart';

class _Content extends StatelessWidget {
  const _Content({required this.user, required this.isLoggedIn});

  final AppSessionUser? user;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return CustomRefresh(
      onRefresh: () async {
        // Deux sources se relisent ici : la fiche de profil et l'espace
        // commercant. La session, elle, est ecoutee et n'a rien a
        // recharger.
        await Future.wait([
          context.read<ProfileCubit>().load(force: true),
          context.read<MerchantCubit>().refresh(),
        ]);
      },
      child: ListView(
        padding: AppDimens.appPadding,
        children: [
          ProfileSummaryCard(
            isLoggedIn: isLoggedIn,
            name: user?.name ?? '',
            email: user?.email ?? '',
            onTap: () => isLoggedIn
                ? showProfileDetailsSheet(context)
                : context.push('/login'),
          ),
          AppDimens.spacerMedium,
          // Section Générale
          GeneralSettingsSection(isLoggedIn: isLoggedIn),
          AppDimens.spacerMedium,
          // La sécurité du compte n'a de sens que connecté : sans session,
          // il n'y a pas de mot de passe à poser.
          if (isLoggedIn) ...[
            const SecuritySettingsSection(),
            AppDimens.spacerMedium,
          ],
          // Section Commerce : la porte d'entrée vers l'espace
          // commerçant, ou vers la demande pour en ouvrir un.
          MerchantSettingsSection(isLoggedIn: isLoggedIn),
          AppDimens.spacerMedium,
          const HelpSettingsSection(),
          AppDimens.spacerMedium,
          // Les textes juridiques. Ils ont eu une section sans
          // destination — deux entrées qui n'ouvraient rien — puis plus
          // de section du tout. Ils reviennent avec leur contenu, lisible
          // dans l'application.
          const LegalSettingsSection(),
          if (isLoggedIn) ...[
            AppDimens.spacerLarge,
            SettingsLogoutButton(
              onTap: () => showLogoutConfirmationDialog(context),
            ),
          ],
          AppDimens.spacerMini,
          const VersionText(),
        ],
      ),
    );
  }
}
