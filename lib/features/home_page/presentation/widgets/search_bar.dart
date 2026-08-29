import 'package:baobabe_0_2/core/widgets/custom_card.dart';
import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final bool autofocus;

  const SearchAppBar({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.hintText = 'Rechercher...',
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      hasPadding: false,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 25,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                fillColor: Colors.transparent,
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

          SizedBox(height: 15),
        ],
      ),
    );
  }
}
