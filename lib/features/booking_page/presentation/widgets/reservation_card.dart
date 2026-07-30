import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: AppColors.transparent,
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
                          color: reservation.typeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radius12,
                          ),
                          border: Border.all(
                            width: 2,
                            color: reservation.typeColor,
                          ),
                        ),
                        child: Icon(
                          reservation.typeIcon,
                          color: reservation.typeColor,
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: AppFonts.bold,
                                fontFamily: AppFonts.primaryFontFamily,
                                color: AppColors.textPrimary,
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
                                    color: reservation.typeColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.radius8,
                                    ),
                                  ),
                                  child: Text(
                                    reservation.typeDisplayName,
                                    style: TextStyle(
                                      color: reservation.typeColor,
                                      fontSize: 12,
                                      fontWeight: AppFonts.bold,
                                      fontFamily: AppFonts.primaryFontFamily,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimens.small),
                                Expanded(
                                  child: Text(
                                    ReservationFormatUtils.getReservationSubtitle(
                                      reservation,
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      fontFamily: AppFonts.primaryFontFamily,
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
                                reservation.displayDate,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppDimens.radius10,
                              ),
                            ),
                            child: Text(
                              ReservationFormatUtils.getStatusText(
                                reservation.displayDate,
                              ),
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: AppFonts.bold,
                                fontFamily: AppFonts.primaryFontFamily,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimens.small),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
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
                      color: reservation.typeColor.withOpacity(0.2),
                      border: Border.all(width: 2, color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: AppFonts.semiBold,
                            color: reservation.typeColor,
                            fontFamily: AppFonts.primaryFontFamily,
                          ),
                        ),
                        Text(
                          '\$${reservation.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: AppFonts.bold,
                            color: reservation.typeColor,
                            fontFamily: AppFonts.primaryFontFamily,
                          ),
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
          child: Text('Erreur d’affichage : $e'),
        ),
      );
    }
  }
}
