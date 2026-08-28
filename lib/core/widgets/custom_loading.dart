import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../themes/app_colors.dart';

/// Le seul indicateur circulaire encore admis dans l'application : celui
/// d'un bouton en cours d'action. Partout ailleurs, un chargement se montre
/// avec un `Skeletonizer` et des `Bone` reprenant la forme du contenu à
/// venir (voir « Loading States » dans .agents/AGENTS.md).
class CustomLoadingButton extends StatelessWidget {
  final Color color;
  final double size;
  const CustomLoadingButton({
    super.key,
    this.color = AppColors.textPrimary,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.inkDrop(size: size, color: color);
  }
}
