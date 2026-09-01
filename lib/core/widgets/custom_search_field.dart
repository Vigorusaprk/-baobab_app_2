import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Le champ de recherche de l'application, dans son unique habillage.
///
/// L'accueil et Explorer le montrent tous les deux et doivent être
/// indiscernables : c'est le même geste, poursuivi d'un écran à l'autre. Sur
/// l'accueil il ne sert qu'à emmener sur Explorer — d'où [readOnly], qui garde
/// l'apparence sans ouvrir le clavier.
///
/// La loupe est dimensionnée **en dur** plutôt que laissée à
/// `InputDecoration`, qui donne au `prefixIcon` une boîte minimale de 48 px et
/// y étire le dessin : l'icône sortait deux fois trop grosse et écrasait le
/// texte. `prefixIconConstraints` reprend la main.
class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.hint = 'Restaurant, concert, cosmétique…',
  });

  final TextEditingController? controller;

  /// Permet à l'écran de donner le focus au champ sans que l'utilisateur ait
  /// à le toucher — quand il arrive d'une barre de recherche déjà touchée
  /// ailleurs, par exemple.
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool autofocus;
  final String hint;

  /// Taille du dessin de la loupe.
  static const double iconSize = 20;

  /// Largeur réservée à la loupe et à sa marge, avant le texte.
  static const double _iconSlot = 46;

  /// Hauteur intrinsèque du champ.
  ///
  /// Exposée parce que [HomeSliverHeader] doit déclarer des extents fixes : un
  /// en-tête qui réserve une autre place que celle réellement occupée fait
  /// sauter la page au défilement.
  static const double height = 48;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        autofocus: autofocus,
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.bodySmall,
        cursorColor: scheme.primary,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: AppDimens.small),
          prefixIconConstraints: const BoxConstraints(
            minWidth: _iconSlot,
            minHeight: height,
          ),
          prefixIcon: Center(
            widthFactor: 1,
            child: SvgPicture.asset(
              'assets/icons/explore-outline.svg',
              height: iconSize,
              width: iconSize,
              colorFilter: ColorFilter.mode(scheme.primary, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
