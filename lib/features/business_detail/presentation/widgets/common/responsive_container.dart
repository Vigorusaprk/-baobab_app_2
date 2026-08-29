import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// La marge latérale d'une page de contenu.
///
/// Elle bornait aussi la largeur au-dessus de 600 px. Ce n'est plus son
/// travail : [AdaptiveViewport] donne sa colonne à l'application entière, une
/// fois pour toutes. Garder ici une seconde règle de largeur revenait à
/// avoir deux réponses à la même question — et une seule page les appliquait.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding ?? AppDimens.appPadding, child: child);
  }
}
