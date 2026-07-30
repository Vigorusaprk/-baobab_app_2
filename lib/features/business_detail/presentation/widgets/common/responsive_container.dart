import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    // On limite la largeur maximale du contenu pour le confort de lecture
    final double maxWidth = width > 600 ? 500 : width;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding ?? AppDimens.appPadding,
        child: child,
      ),
    );
  }
}
