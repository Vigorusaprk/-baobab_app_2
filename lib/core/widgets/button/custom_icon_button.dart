import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Le fond d'un [CustomIconButton], selon le poids qu'on veut lui donner.
enum IconButtonTone {
  /// Aplat de la couleur d'action : le bouton se voit en premier.
  filled,

  /// Fond de carte, ombre douce : le bouton accompagne sans réclamer.
  surface,
}

/// Le bouton carré qui ne porte qu'une icône.
///
/// Il y en avait quatre versions écrites à la main — la loupe de l'accueil,
/// la cloche de notifications, le filtre de la recherche — chacune avec son
/// propre rayon (10, 20, celui de `CustomCard`) et son propre `Container`
/// décoré. Trois rayons pour un même objet, et une cible tactile de 41 px
/// alors que `AppDimens.touchTarget` documente 48 comme le minimum.
///
/// Ce widget règle les trois : rayon [AppDimens.borderRadiusSmallButton],
/// carré, et jamais plus petit que la cible tactile.
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    this.assetPath,
    this.icon,
    this.tone = IconButtonTone.surface,
    this.iconSize = 24,
  }) : assert(
         assetPath != null || icon != null,
         'Un bouton icône a besoin de son icône : assetPath ou icon.',
       );

  final VoidCallback onPressed;

  /// Ce que le bouton fait, en toutes lettres.
  ///
  /// Obligatoire : une icône seule est une devinette, et c'est le seul texte
  /// qu'un lecteur d'écran pourra annoncer.
  final String tooltip;

  /// Icône vectorielle depuis `assets/icons/`.
  final String? assetPath;

  /// Icône Material, quand il n'y a pas d'asset dédié.
  final IconData? icon;

  final IconButtonTone tone;
  final double iconSize;

  bool get _isFilled => tone == IconButtonTone.filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = _isFilled
        ? scheme.primary
        : scheme.surfaceContainerLowest;
    final foreground = _isFilled ? scheme.onPrimary : scheme.primary;
    const radius = BorderRadius.all(
      Radius.circular(AppDimens.borderRadiusSmallButton),
    );

    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: radius,
        // L'ombre n'appartient qu'au ton `surface` : sur un aplat de couleur
        // elle salit le bord sans rien apporter.
        elevation: _isFilled ? 0 : AppDimens.elevationDefault,
        shadowColor: scheme.onSurface.withValues(alpha: 0.10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: ConstrainedBox(
            // Carré, et jamais sous la cible qu'un doigt vise sans effort.
            constraints: const BoxConstraints(
              minWidth: AppDimens.touchTarget,
              minHeight: AppDimens.touchTarget,
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.small),
                child: _Glyph(
                  assetPath: assetPath,
                  icon: icon,
                  size: iconSize,
                  color: foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph({
    required this.assetPath,
    required this.icon,
    required this.size,
    required this.color,
  });

  final String? assetPath;
  final IconData? icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path != null) {
      return SvgPicture.asset(
        path,
        height: size,
        width: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return Icon(icon, size: size, color: color);
  }
}
