import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../themes/app_colors.dart';

class CustomLoadingButton extends StatelessWidget {
  final Color color;
  final double size;
  const CustomLoadingButton({
    super.key,
    this.color = AppColors.textColor,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.inkDrop(size: size, color: color);
  }
}

class CustomLoadingPage extends StatelessWidget {
  final Color color;
  final double size;
  const CustomLoadingPage({
    super.key,
    this.color = AppColors.textColor,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.inkDrop(size: size, color: color);
  }
}

class CustomConnexionLoading extends StatelessWidget {
  final Color color;
  final double size;
  const CustomConnexionLoading({
    super.key,
    this.color = AppColors.textColor,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.inkDrop(size: size, color: color);
  }
}
