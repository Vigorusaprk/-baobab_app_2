import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';

/// Puce de filtre par statut de commande, utilisée dans [OrderScreen].
class OrderFilterChip extends StatelessWidget {
  final String label;
  final OrderStatus? status;
  final bool isSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? labelColor;
  final Color? selectedLabelColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool showIcon;
  final IconData? icon;
  final VoidCallback? onTap;

  const OrderFilterChip({
    super.key,
    required this.label,
    required this.status,
    required this.isSelected,
    this.selectedColor,
    this.unselectedColor,
    this.labelColor,
    this.selectedLabelColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.showIcon = true,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.secondaryLight;
    final effectiveUnselectedColor =
        unselectedColor ?? AppColors.textSecondary.withOpacity(0.3);
    final effectiveLabelColor = AppColors.secondary;
    final effectiveSelectedLabelColor =
        selectedLabelColor ?? AppColors.background;
    final effectiveFontSize = fontSize ?? 14;
    final effectiveFontWeight = fontWeight ?? FontWeight.w500;
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final effectiveBorderRadius = borderRadius ?? 20.0;

    return Padding(
      padding: EdgeInsetsGeometry.only(left: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveSelectedColor
                : effectiveUnselectedColor,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: effectiveSelectedColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? effectiveSelectedLabelColor
                      : effectiveLabelColor,
                  fontSize: effectiveFontSize,
                  fontWeight: effectiveFontWeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
