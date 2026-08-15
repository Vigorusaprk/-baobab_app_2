import 'package:flutter/material.dart';

/// Conteneur vide pour une carte business. Juste la forme/dimensions,
/// aucun contenu ni style final — à remplir toi-même.
class BusinessCardPlaceholder extends StatelessWidget {
  final VoidCallback? onTap;

  const BusinessCardPlaceholder({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // TODO: remplace ce contenu par le vrai design de la business_card.
      ),
    );
  }
}
