import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

class SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final bool autofocus;

  const SearchAppBar({
    Key? key,
    required this.controller,
    this.onSubmitted,
    this.hintText = 'Rechercher...',
    this.autofocus = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                controller.clear();
                onSubmitted?.call('');
              },
            ),
        ],
      ),
    );
  }
}