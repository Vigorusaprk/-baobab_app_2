import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

/// Le bouton d'action principal de l'application : pleine largeur, aplat de
/// la couleur d'action, effet d'appui, et un état de chargement.
///
/// Tout bouton principal passe par lui. Neuf écrans en avaient reconstruit un
/// à la main avec `FilledButton.styleFrom(...)` — même forme approximative,
/// mais chacun son rayon, son remplissage, et aucun n'avait l'état de
/// chargement ni l'effet d'appui.
class CustomButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isActive;

  /// Pictogramme facultatif, placé avant le libellé.
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isActive = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: AppMotion.duration(context, AppMotion.base),
          curve: AppMotion.standard,
          decoration: BoxDecoration(
            color: isLoading
                ? Theme.of(context).colorScheme.outlineVariant
                : (isActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppDimens.borderButton),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: isLoading || !isActive ? null : onPressed,
            child: AnimatedSwitcher(
              duration: AppMotion.duration(context, AppMotion.base),
              child: isLoading
                  ? CustomLoadingButton(
                      key: const ValueKey('loading'),
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : Row(
                      key: ValueKey(text),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20),
                          const SizedBox(width: AppDimens.small),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
