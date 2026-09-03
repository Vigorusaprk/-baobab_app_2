import 'package:flutter/material.dart';

/// Un filet en pointillés, comme la perforation d'un reçu papier.
///
/// `Divider` trace un trait plein : sur un reçu, il ferait cadre. Celui-ci
/// se dessine à la craie et laisse le bloc respirer.
class DashedRule extends StatelessWidget {
  const DashedRule({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.22);

    return LayoutBuilder(
      builder: (context, constraints) {
        const dash = 4.0;
        const gap = 5.0;
        final count = (constraints.maxWidth / (dash + gap)).floor();
        return Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              ColoredBox(
                color: color,
                child: const SizedBox(width: dash, height: 1),
              ),
              if (i != count - 1) const SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}
