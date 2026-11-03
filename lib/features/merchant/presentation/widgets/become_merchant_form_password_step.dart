part of 'become_merchant_sheet.dart';

/// L'étape « Sécurisez votre accès marchand », avant l'envoi de la demande.
///
/// Un commerçant qui n'a pas de mot de passe doit en poser un : c'est lui qui
/// devra le saisir à l'avenir à l'ouverture de Baobab Business. Si le mot de
/// passe est déjà enregistré, l'étape ne s'affiche pas et la demande part
/// directement.
class _MerchantPasswordStep extends StatelessWidget {
  const _MerchantPasswordStep({
    required this.passwordController,
    required this.confirmationController,
    required this.onValidated,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmationController;
  final ValueChanged<String> onValidated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sécurisez votre accès marchand',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimens.spacerMini,
        Text(
          'Ce mot de password vous servira à vous connecter à Baobab Business, '
          'l\'application des commerçants.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerSmall,
        PasswordField(
          controller: passwordController,
          label: 'Mot de passe',
          hint: '10 caractères minimum, une lettre et un chiffre',
        ),
        AppDimens.spacerSmall,
        PasswordField(
          controller: confirmationController,
          label: 'Confirmation',
          hint: 'Saisissez le même mot de passe',
        ),
        AppDimens.spacerLarge,
        CustomButton(
          text: 'Définir le mot de passe',
          isActive: true,
          onPressed: () {
            final password = passwordController.text;
            final confirmation = confirmationController.text.trim();
            if (confirmation != password.trim()) return;
            onValidated(password);
          },
        ),
      ],
    );
  }
}
