import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback onRemoved;
  final Color? color;
  final IconData? icon;

  const FilterChipWidget({
    Key? key,
    required this.label,
    required this.onRemoved,
    this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: color ?? Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: (color ?? Theme.of(context).colorScheme.secondary)
            .withOpacity(0.1),
        side: BorderSide(
          color: (color ?? Theme.of(context).colorScheme.secondary).withOpacity(
            0.3,
          ),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        avatar: icon != null
            ? Icon(
                icon,
                size: 14,
                color: color ?? Theme.of(context).colorScheme.secondary,
              )
            : null,
        deleteIcon: Icon(
          Icons.close,
          size: 16,
          color: color ?? Theme.of(context).colorScheme.secondary,
        ),
        onDeleted: onRemoved,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }
}
