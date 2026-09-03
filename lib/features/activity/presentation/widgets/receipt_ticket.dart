import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Le talon détachable d'un reçu : le code à présenter au commerce.
///
/// Deux entailles rondes en haut le font lire comme un ticket qu'on détache,
/// plutôt que comme une carte de plus. C'est le seul endroit de
/// l'application où une forme imite un objet réel, et c'est voulu : ce bloc
/// **se montre à quelqu'un**, il n'est pas là pour être lu par son
/// propriétaire.
///
/// [locked] grise l'ensemble et remplace la note : un code qui ne sera actif
/// qu'une fois la réservation confirmée ne doit pas avoir l'air utilisable.
class ReceiptTicket extends StatelessWidget {
  const ReceiptTicket({
    super.key,
    required this.payload,
    required this.code,
    required this.note,
    this.locked = false,
  });

  /// Ce que le QR encode réellement.
  final String payload;

  /// Le code lisible, pour la saisie à la main quand le scan échoue.
  final String code;

  final String note;
  final bool locked;

  /// Le diamètre des entailles. Elles mordent sur le bord du talon, d'où le
  /// décalage négatif de la moitié.
  static const double _notch = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Opacity(
      opacity: locked ? 0.45 : 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.medium,
              vertical: AppDimens.large,
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppDimens.radius8),
            ),
            child: Column(
              children: [
                Text(
                  'À PRÉSENTER AU COMMERCE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.4,
                  ),
                ),
                AppDimens.spacerMedium,
                // Un vrai QR, encodant un identifiant réel : le jour où un
                // scanner existe, il aura quelque chose à interroger.
                QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: 148,
                  backgroundColor: scheme.surfaceContainerLowest,
                  padding: const EdgeInsets.all(AppDimens.small),
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: scheme.onSurface,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: scheme.onSurface,
                  ),
                ),
                AppDimens.spacerMedium,
                Text(
                  code,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    // L'espacement large sert la lecture à voix haute et la
                    // recopie : c'est un code qu'on dicte au comptoir.
                    letterSpacing: 3,
                  ),
                ),
                AppDimens.spacerSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (locked) ...[
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: scheme.primary,
                      ),
                      AppDimens.spacerMiniWidth,
                    ],
                    Flexible(
                      child: Text(
                        note,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: locked
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Les entailles reprennent la couleur du fond de la page, pas une
          // couleur à elles : c'est ce qui donne l'illusion du papier percé.
          Positioned(left: -_notch / 2, top: -_notch / 2, child: _Notch()),
          Positioned(right: -_notch / 2, top: -_notch / 2, child: _Notch()),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ReceiptTicket._notch,
      height: ReceiptTicket._notch,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
    );
  }
}

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
