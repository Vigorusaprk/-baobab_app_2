import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  Color? color,
  double? minHeight,
}) {
  final bgColor = color ?? Theme.of(context).scaffoldBackgroundColor;
  final media = MediaQuery.of(context);
  final screenHeight = media.size.height;
  final screenWidth = media.size.width;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      minWidth: screenWidth,
      minHeight: minHeight != null ? screenHeight * minHeight : 0,
      maxHeight: screenHeight * 0.95,
    ),
    builder: (ctx) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, sheetChild) {
          return Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: Opacity(opacity: value, child: sheetChild),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.bottomSheet),
            ),
            //border: Border.all(color: Theme.of(ctx).textTheme.bodyLarge!.color!.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.scrim.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 14,
              left: 22,
              right: 22,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final handleHeight = 5.0;
                const spacing = 20.0;
                final scrollMaxHeight =
                    (constraints.maxHeight - handleHeight - spacing - 8).clamp(
                      0.0,
                      double.infinity,
                    );

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: handleHeight,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadiusFull,
                        ),
                      ),
                    ),
                    const SizedBox(height: spacing),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: scrollMaxHeight),
                      child: SingleChildScrollView(child: child),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
