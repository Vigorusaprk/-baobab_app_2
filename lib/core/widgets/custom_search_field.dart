import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Le champ de recherche de l'application, dans son unique habillage.
///
/// L'accueil et Explorer le montrent tous les deux, et ils doivent être
/// indiscernables : c'est le même geste, poursuivi d'un écran à l'autre. Sur
/// l'accueil il ne sert qu'à emmener sur Explorer — d'où [readOnly], qui
/// garde l'apparence sans ouvrir le clavier.
///
/// [height] est la hauteur intrinsèque, exposée parce que [HomeSliverHeader]
/// doit déclarer des tailles fixes : un en-tête qui réserve une autre place
/// que celle réellement occupée fait sauter la page au défilement.
class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    this.controller,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.hint = 'Restaurant, concert, cosmétique…',
  });

  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool autofocus;
  final String hint;

  static const double iconSize = 10;
  static const double height = AppDimens.small * 2 + iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        autofocus: autofocus,
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.labelMedium,
        cursorColor: scheme.primary,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: SizedBox(
            height: height,
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
