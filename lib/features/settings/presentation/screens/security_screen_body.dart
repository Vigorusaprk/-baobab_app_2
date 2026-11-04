part of 'security_screen.dart';

/// Le contenu de la page Sécurité : le titre suit l'état du compte, le
/// formulaire pose le mot de passe, le texte d'aide dit comment s'en
/// sortir si on l'a oublié.
class _SecurityBody extends StatelessWidget {
  const _SecurityBody({
    required this.isSubmitting,
    required this.error,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final String? error;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final email = SessionService.instance.currentUser?.email;

    return BlocBuilder<SecurityCubit, SecurityState>(
      builder: (context, state) {
        return ListView(
          padding: AppDimens.appPadding.copyWith(
            top: AppDimens.small,
            bottom: AppDimens.large,
          ),
          children: [
            Text(
              state.hasPassword
                  ? 'Changer mon mot de passe'
                  : 'Définir un mot de passe',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppDimens.spacerMini,
            Text(
              'Ce mot de passe servira à vous connecter à Baobab Business, '
              'l\'application des commerçants.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            AppDimens.spacerLarge,
            SetPasswordForm(
              email: email,
              isLoading: isSubmitting,
              error: error,
              onSubmit: onSubmit,
            ),
            AppDimens.spacerMedium,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimens.small),
                Expanded(
                  child: Text(
                    'Mot de passe perdu ? Connectez-vous par code e-mail, '
                    'puis définissez-en un nouveau ici.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
