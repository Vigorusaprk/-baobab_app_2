import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Le poids d'un [CustomActionButton].
enum ActionButtonTone {
  /// Aplat de la couleur d'action. C'est l'action que l'on veut voir.
  filled,

  /// Aplat discret, texte dans la couleur d'action : une action secondaire
  /// qui ne doit pas rivaliser avec le bouton principal de l'écran.
  tonal,

  /// Aplat rouge : « Refuser », « Retirer », ce qui ne se reprend pas.
  danger,
}

/// Le bouton d'action **compact** de l'application.
///
/// [CustomButton] tient toute la largeur : c'est le bouton qui conclut un
/// formulaire. Celui-ci se pose dans une ligne, une carte, une barre — là où
/// un bouton pleine largeur n'a pas de sens.
///
/// Il existe surtout pour une raison de lisibilité. Les boutons écrits à la
/// main donnaient leur libellé ainsi :
///
/// ```dart
/// FilledButton.icon(
///   style: FilledButton.styleFrom(backgroundColor: scheme.primary),
///   label: Text('Écrire un avis', style: textTheme.bodySmall),
/// )
/// ```
///
/// Un style pris dans `textTheme` **porte sa couleur** — celle du texte de
/// page, sombre — et un style posé sur un `Text` l'emporte sur la couleur du
/// bouton. Le libellé se retrouvait donc en gris foncé sur le vert d'action :
/// illisible. « Écrire un avis » et « Découvrir les commerces » étaient dans
/// ce cas.
///
/// Ici l'appelant ne choisit pas la couleur du texte : le bouton la déduit de
/// son fond, et la faute ne peut plus revenir.
class CustomActionButton extends StatelessWidget {
  const CustomActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.assetPath,
    this.tone = ActionButtonTone.filled,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;

  /// `null` désactive le bouton — l'état grisé vient du thème.
  final VoidCallback? onPressed;

  /// Pictogramme Material, placé avant le libellé.
  final IconData? icon;

  /// Pictogramme vectoriel depuis `assets/icons/`, teinté comme le libellé.
  final String? assetPath;

  final ActionButtonTone tone;
  final bool isLoading;

  /// Prend toute la largeur disponible. Par défaut le bouton s'ajuste à son
  /// contenu, ce qui est le propre d'un bouton compact.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (background, foreground) = switch (tone) {
      ActionButtonTone.filled => (scheme.primary, scheme.onPrimary),
      ActionButtonTone.tonal => (
        scheme.surfaceContainerHighest,
        scheme.primary,
      ),
      ActionButtonTone.danger => (scheme.error, scheme.onError),
    };

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: AppDimens.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimens.borderRadiusSmallButton,
          ),
        ),
        // Jamais sous la cible qu'un doigt vise sans effort.
        minimumSize: const Size(0, AppDimens.touchTarget),
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.duration(context, AppMotion.base),
        child: isLoading
            ? CustomLoadingButton(
                key: const ValueKey('loading'),
                size: 18,
                color: foreground,
              )
            : Row(
                key: ValueKey(label),
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null || assetPath != null) ...[
                    _Glyph(
                      icon: icon,
                      assetPath: assetPath,
                      color: foreground,
                      size: theme.textTheme.labelLarge?.fontSize ?? 14,
                    ),
                    const SizedBox(width: AppDimens.small),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // La couleur vient du fond, pas de l'appelant : c'est
                      // toute la raison d'être de ce widget.
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    return PressEffect(
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph({
    required this.icon,
    required this.assetPath,
    required this.color,
    required this.size,
  });

  final IconData? icon;
  final String? assetPath;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path != null) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return Icon(icon, size: size, color: color);
  }
}
