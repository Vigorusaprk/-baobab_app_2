part of 'become_merchant_sheet.dart';

/// L'explication sur la publication, derrière un bouton d'information. Elle
/// occupait le haut de l'écran à chaque visite alors qu'on ne la lit qu'une
/// fois.
class _MerchantExplanation extends StatefulWidget {
  const _MerchantExplanation({
    required this.isOpen,
    required this.onToggle,
  });

  final bool isOpen;
  final VoidCallback onToggle;

  @override
  State<_MerchantExplanation> createState() => _MerchantExplanationState();
}

class _MerchantExplanationState extends State<_MerchantExplanation> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: CustomIconButton(
            onPressed: widget.onToggle,
            tooltip: widget.isOpen
                ? 'Masquer l\'explication'
                : 'À quoi sert un compte commerçant ?',
            icon: widget.isOpen
                ? Icons.info_rounded
                : Icons.info_outline_rounded,
            tone: IconButtonTone.ghost,
            iconSize: AppDimens.large,
          ),
        ),
        AnimatedSize(
          duration: AppMotion.duration(context, AppMotion.base),
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: widget.isOpen
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.medium),
                  child: Text(
                    'Publiez vos produits et vos services sur Baobabe. Vos '
                    'clients les commandent ou les réservent depuis '
                    'l\'application, et vous les gérez depuis votre espace '
                    'commerçant.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
