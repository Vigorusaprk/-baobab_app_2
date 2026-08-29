import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

/// Titre d'une section de la fiche commerçant.
///
/// Partagé par les sections qui composent la page : elles sont désormais
/// posées une à une par l'écran, dans un ordre qui suit ce que
/// l'utilisateur cherche — ce qu'est ce commerce, ce qu'il propose, comment
/// le joindre, quand il ouvre, ce qu'on en dit.
class BusinessSectionTitle extends StatelessWidget {
  final String title;

  const BusinessSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// « À propos » : la présentation du commerce.
///
/// Disparaît entièrement quand le commerçant n'a rien écrit — un titre
/// suivi d'un cadre vide n'apprend rien.
class BusinessAboutSection extends StatelessWidget {
  final Business business;

  const BusinessAboutSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    if (business.description.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BusinessSectionTitle('À propos'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            business.description,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
