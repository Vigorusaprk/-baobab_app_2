part of 'merchant_agenda.dart';

/// Un rendez-vous : l'heure d'abord, puis qui et quoi.
class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.reservation});

  final ReceivedReservation reservation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final other = OtherTheme.of(context);
    final pending = reservation.status == ReservationStatus.pending;

    return MerchantCard(
      // Deux rangées, pas une. Les deux pastilles d'action vivaient dans la
      // colonne du milieu, coincées entre le filet et la pastille d'état :
      // la rangée dépassait de son `Expanded`, et Flutter ne teste pas les
      // touchers hors des limites du parent. « Refuser » était donc peint en
      // entier mais ne répondait que sur sa moitié gauche — un bouton qui
      // ignore un doigt posé dessus est pire qu'un bouton absent. Les
      // actions ont maintenant la largeur de la carte pour elles seules.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.date == null
                        ? '--:--'
                        : DateFormat('HH:mm').format(reservation.date!),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                  if (reservation.quantity > 1)
                    Text(
                      '×${reservation.quantity}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              AppDimens.spacerMediumWidth,
              Container(width: 2, height: 40, color: scheme.primaryContainer),
              AppDimens.spacerMediumWidth,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppDimens.spacerMini,
                    Text(
                      reservation.customer?.name ?? 'Client',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppDimens.spacerSmallWidth,
              StatusChip(
                label: reservation.status.label,
                color: pending
                    ? other.onWarningContainer
                    : other.onSuccessContainer,
                surface: pending
                    ? other.warningContainer
                    : other.successContainer,
              ),
            ],
          ),
          if (pending) ...[
            AppDimens.spacerSmall,
            // Moitié-moitié : deux cibles de même taille, sur toute la
            // largeur. Le geste ne demande plus de viser.
            Row(
              children: [
                Expanded(
                  child: _MiniAction(
                    label: 'Confirmer',
                    icon: Icons.check_rounded,
                    onTap: () => context
                        .read<MerchantCubit>()
                        .updateReservationStatus(reservation.id, 'confirmed'),
                  ),
                ),
                AppDimens.spacerSmallWidth,
                Expanded(
                  child: _MiniAction(
                    label: 'Refuser',
                    icon: Icons.close_rounded,
                    tint: scheme.error,
                    onTap: () => _refuse(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Refuser libère le créneau et prévient le client, sans retour. Les deux
  /// pastilles se touchent du pouce : on pose la question avant d'agir.
  Future<void> _refuse(BuildContext context) async {
    final cubit = context.read<MerchantCubit>();
    final confirmed = await showCustomPopUp(
      context: context,
      title: 'Refuser ce rendez-vous ?',
      message:
          'Le créneau est libéré tout de suite et le client en est '
          'prévenu. Cela ne peut pas être défait.',
      confirmLabel: 'Refuser',
    );
    if (!confirmed) return;
    await cubit.updateReservationStatus(reservation.id, 'cancelled');
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tint,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tint ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
        child: Container(
          height: AppDimens.touchTarget,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
            border: Border.all(color: color),
          ),
          // Centré : la pastille prend maintenant la moitié de la carte, et
          // un libellé collé à gauche flotterait dans le vide.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              AppDimens.spacerMiniWidth,
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
