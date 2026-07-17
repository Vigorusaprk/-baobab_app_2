import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.scaffoldBackgroundColor,
          ),
          child: SvgPicture.asset(
            "assets/icons/olive-svgrepo-com.svg",
            height: 48,
            colorFilter: ColorFilter.mode(
              theme.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bienvenue',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: theme.scaffoldBackgroundColor,
          ),
        ),
        Text(
          'Heureux de vous revoir !',
          style: TextStyle(fontSize: 16, color: theme.primaryColor),
        ),
      ],
    );
  }
}