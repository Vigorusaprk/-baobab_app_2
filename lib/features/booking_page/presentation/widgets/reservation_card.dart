import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/utils/reservation_format_utils.dart';
import 'reservation_type_details_a.dart';

/// Card summarizing a single reservation, with type-specific details and a
/// delete action.
class ReservationCard extends StatelessWidget {
  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onDelete,
  });

  final Reservation reservation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    try {
      return Container(
        margin: const EdgeInsets.only(bottom: AppDimens.medium),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimens.radius20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                context.pushNamed('reservationDetail', extra: reservation),
            borderRadius: BorderRadius.circular(AppDimens.radius20),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête (icône, nom, statut)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: reservation
                              .typeColor(context)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radius12,
                          ),
                          border: Border.all(
                            width: 2,
                            color: reservation.typeColor(context),
                          ),
                        ),
                        child: Icon(
                          reservation.typeIcon,
                          color: reservation.typeColor(context),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppDimens.medium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reservation.establishmentName,
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppDimens.small),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.small,
                                    vertical: AppDimens.small,
                                  ),
                                  decoration: BoxDecoration(
                                    color: reservation
                                        .typeColor(context)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.radius8,
                                    ),
                                  ),
                                  child: Text(
                                    reservation.typeDisplayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: reservation.typeColor(context),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppDimens.small),
                                Expanded(
                                  child: Text(
                                    ReservationFormatUtils.getReservationSubtitle(
                                      reservation,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.small,
                              vertical: AppDimens.small,
                            ),
                            decoration: BoxDecoration(
                              color: ReservationFormatUtils.getStatusColor(
                                context,
                                reservation,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppDimens.radius10,
                              ),
                            ),
                            child: Text(
                              ReservationFormatUtils.getStatusText(reservation),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                            ),
                          ),
                          const SizedBox(height: AppDimens.small),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: AppDimens.touchTarget,
                              minHeight: AppDimens.touchTarget,
                            ),
                            tooltip: 'Supprimer cette réservation',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.medium),
                  // Détails spécifiques
                  if (reservation.type == 'hotel')
                    HotelReservationDetails(reservation)
                  else if (reservation.type == 'restaurant')
                    RestaurantReservationDetails(reservation)
                  else if (reservation.type == 'car_rental')
                    CarRentalReservationDetails(reservation)
                  else if (reservation.type == 'travel')
                    TravelReservationDetails(reservation)
                  else if (reservation.type == 'spa')
                    SpaReservationDetails(reservation)
                  else if (reservation.type == 'cinema')
                    CinemaReservationDetails(reservation)
                  else if (reservation.type == 'toursime')
                    TourismReservationDetails(reservation),
                  const SizedBox(height: AppDimens.medium),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.medium),
                    decoration: BoxDecoration(
                      color: reservation.typeColor(context).withOpacity(0.2),
                      border: Border.all(
                        width: 2,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: reservation.typeColor(context),
                              ),
                        ),
                        Text(
                          '\$${reservation.totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: reservation.typeColor(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e, stack) {
      print('❌ Erreur affichage carte : $e');
      print(stack);
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Cette ligne n’a pas pu s’afficher.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
