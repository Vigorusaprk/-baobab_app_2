import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/core/widgets/dashed_rule.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/features/activity/domain/activity_entry.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/receipt_ticket.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/reservation_type_details.dart';

/// Le détail d'une activité, sous la forme d'un reçu.
///
/// Il n'y avait rien : une carte dans une liste, avec deux boutons. Or ce
/// qu'on vient chercher ici est précis — ce que j'ai demandé, où j'en suis,
/// combien, et quoi montrer au comptoir. Un reçu répond aux quatre dans
/// l'ordre où on se les demande.
///
/// Il se pose dans [ActivityDetailPage], qui est une page entière : le reçu
/// occupe l'écran, sans barre de navigation sous lui.
class ActivityReceipt extends StatelessWidget {
  const ActivityReceipt({
    super.key,
    required this.entry,
    required this.onBack,
    this.onCancel,
    this.onRate,
  });

  final ActivityEntry entry;
  final VoidCallback onBack;
  final VoidCallback? onCancel;
  final VoidCallback? onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ColoredBox(
      color: scheme.surfaceContainerLowest,
      child: Column(
        children: [
          _Bar(entry: entry, onBack: onBack),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppDimens.large,
                AppDimens.small,
                AppDimens.large,
                // Le reçu est une page : plus de barre de navigation à
                // éviter, mais la barre de gestes du système reste, et le
                // bord à bord est imposé depuis la cible API 35.
                MediaQuery.viewPaddingOf(context).bottom + AppDimens.large,
              ),
              children: [
                Text(
                  entry.businessName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                if (_address(entry) != null) ...[
                  AppDimens.spacerSmall,
                  Text(
                    _address(entry)!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                AppDimens.spacerLarge,

                const DashedRule(),
                _StatusBand(entry: entry),
                const DashedRule(),
                AppDimens.spacerMedium,

                ..._lines(context),

                AppDimens.spacerMedium,
                const DashedRule(),
                AppDimens.spacerMedium,
                _TotalRow(total: entry.total),
                AppDimens.spacerLarge,

                ReceiptTicket(
                  payload: entry.qrPayload,
                  code: entry.code,
                  locked: _isLocked,
                  note: _isLocked
                      ? 'Actif dès que la réservation est confirmée.'
                      : 'Le commerçant scanne le code, ou saisit les 8 '
                            'chiffres.',
                ),
                AppDimens.spacerMedium,

                Text(
                  'Paiement sur place, à la livraison. Baobabe ne vend pas et '
                  'n\'encaisse rien : le montant est celui fixé par le '
                  'commerce.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                AppDimens.spacerLarge,

                _Actions(entry: entry, onCancel: onCancel, onRate: onRate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Un code de réservation non confirmée ne sert à rien : le montrer actif
  /// enverrait quelqu'un au comptoir pour rien.
  bool get _isLocked => entry.kind == ActivityKind.booking && entry.step < 2;

  /// L'adresse de livraison, quand il y en a une.
  ///
  /// **Pas le téléphone.** `Order.customerPhone` et
  /// `Reservation.phoneNumber` sont ceux du *client* : les afficher sur son
  /// propre reçu n'apprend rien, et le composer reviendrait à s'appeler
  /// soi-même. Le téléphone du commerce vit sur `business.phone`, que ni
  /// l'une ni l'autre de ces entités ne rapatrie — d'où l'absence du bouton
  /// « Appeler » que la maquette prévoyait.
  static String? _address(ActivityEntry entry) {
    final address = entry.order?.deliveryAddress;
    return (address?.isNotEmpty ?? false) ? address : null;
  }

  /// Ce qui a été demandé. Pour une commande, les articles ; pour une
  /// réservation, ce qui la caractérise — la date, le nombre de places.
  List<Widget> _lines(BuildContext context) {
    final order = entry.order;
    if (order != null) {
      return [
        for (final item in order.items)
          _ItemLine(
            quantity: '×${item.quantity}',
            label: item.name,
            price: item.price * item.quantity,
          ),
      ];
    }

    final reservation = entry.reservation;
    if (reservation == null) return const [];
    return [
      _ItemLine(
        quantity: '×1',
        label: reservation.reservationType,
        price: reservation.totalAmount,
      ),
      AppDimens.spacerSmall,
      _MetaLine(
        icon: Icons.calendar_today_outlined,
        text: DateFormat(
          'EEEE d MMMM · HH:mm',
          'fr_FR',
        ).format(reservation.reservationDate),
      ),
      // Le détail propre au type — chambre et dates pour un hôtel, sièges
      // pour un cinéma, jours et chauffeur pour une location. Ces blocs
      // existaient déjà dans l'ancienne carte : les laisser de côté aurait
      // rendu le nouveau reçu moins informatif que ce qu'il remplace.
      Padding(
        padding: const EdgeInsets.only(left: 28),
        child: ReservationTypeDetails(reservation: reservation),
      ),
      if (reservation.notes?.isNotEmpty ?? false)
        _MetaLine(icon: Icons.sticky_note_2_outlined, text: reservation.notes!),
    ];
  }
}

/// La barre du haut : retour, référence, partage.
class _Bar extends StatelessWidget {
  const _Bar({required this.entry, required this.onBack});

  final ActivityEntry entry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.small,
        right: AppDimens.small,
        // Cet onglet n'a pas d'app bar : la barre d'état est à notre charge,
        // sinon la référence se peint par-dessus l'heure du système.
        top: MediaQuery.paddingOf(context).top + AppDimens.small,
      ),
      child: Row(
        children: [
          CustomIconButton(
            onPressed: onBack,
            tooltip: 'Retour au flux',
            icon: Icons.arrow_back_rounded,
            tone: IconButtonTone.ghost,
            iconSize: AppDimens.medium + 2,
          ),
          Expanded(
            child: Text(
              entry.reference,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// L'état, encadré de deux perforations : c'est la seule chose qu'on lit
/// avant de savoir si l'on a besoin du reste.
class _StatusBand extends StatelessWidget {
  const _StatusBand({required this.entry});

  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = entry.isCancelled ? scheme.error : scheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.medium),
      child: Row(
        children: [
          Icon(entry.statusIcon, size: AppDimens.large, color: color),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.statusLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.statusNote != null) ...[
                  AppDimens.spacerMini,
                  Text(
                    entry.statusNote!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (entry.step > 0)
            Text(
              '${entry.step}/${entry.stepCount}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemLine extends StatelessWidget {
  const _ItemLine({
    required this.quantity,
    required this.label,
    required this.price,
  });

  final String quantity;
  final String label;
  final double price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.small + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              quantity,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          AppDimens.spacerSmallWidth,
          Text(
            price.toStringAsFixed(2).replaceAll('.', ','),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Icon(icon, size: 15, color: theme.colorScheme.primary),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'TOTAL',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.6,
          ),
        ),
        const Spacer(),
        Text(
          '${total.toStringAsFixed(2).replaceAll('.', ',')} \$',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.entry,
    required this.onCancel,
    required this.onRate,
  });

  final ActivityEntry entry;
  final VoidCallback? onCancel;
  final VoidCallback? onRate;

  @override
  Widget build(BuildContext context) {
    // Une seule action à la fois : noter ce qui est livré, ou annuler ce qui
    // ne l'est pas encore. Elles tiennent toute la largeur — au pied d'une
    // page entière, un bouton court flotte sans appui.
    if (onRate != null) {
      return CustomActionButton(
        label: 'Noter cette commande',
        tone: ActionButtonTone.tonal,
        icon: Icons.star_outline_rounded,
        onPressed: onRate,
        expand: true,
      );
    }
    if (onCancel != null) {
      // Tracé, pas rempli : un aplat rouge pleine largeur crierait plus fort
      // que ce qu'il propose, et la confirmation qui suit porte déjà le
      // poids du geste.
      return CustomActionButton(
        label: entry.kind.isOrder
            ? 'Annuler la commande'
            : 'Annuler la réservation',
        tone: ActionButtonTone.dangerOutline,
        onPressed: onCancel,
        expand: true,
      );
    }
    return const SizedBox.shrink();
  }
}
