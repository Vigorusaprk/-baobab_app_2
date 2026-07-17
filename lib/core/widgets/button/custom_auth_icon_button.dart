import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomAuthIconButton extends StatelessWidget {
  const CustomAuthIconButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusAuthIconButton),
        ),
        margin: EdgeInsets.only(
          right: AppDimens.marginExtraSmall,
          top: AppDimens.marginExtraSmall,
          bottom: AppDimens.marginExtraSmall,
        ),
        child: GestureDetector(
          onTap: onPressed,
          child: Padding(
            padding: AppDimens.allPadding8,
            child: loading
                ? LoadingAnimationWidget.hexagonDots(
                    color: Theme.of(context).cardColor,
                    size: 15,
                  )
                : Icon(Icons.arrow_forward, color: Theme.of(context).cardColor),
          ),
        ),
      ),
    );
  }
}