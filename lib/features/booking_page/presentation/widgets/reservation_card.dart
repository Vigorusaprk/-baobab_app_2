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
        margin: const EdgeInsets.only(bottom: AppDimens.PADDING_16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
            borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.PADDING_16),
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
                            AppDimens.BORDER_RADIUS_12,
                          ),
                          border: Border.all(width: 2, color: reservation.typeColor),
                        ),
                        child: Icon(
                          reservation.typeIcon,
                          color: reservation.typeColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppDimens.PADDING_16),
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
                            const SizedBox(height: AppDimens.PADDING_4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.PADDING_8,
                                    vertical: AppDimens.PADDING_4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: reservation.typeColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.BORDER_RADIUS_8,
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
                                const SizedBox(width: AppDimens.PADDING_8),
                                Expanded(
                                  child: Text(
                                    ReservationFormatUtils
                                        .getReservationSubtitle(reservation),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
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
                              horizontal: AppDimens.PADDING_10,
                              vertical: AppDimens.PADDING_5,
                            ),
                            decoration: BoxDecoration(
                              color: ReservationFormatUtils.getStatusColor(
                                  reservation.displayDate),
                              borderRadius: BorderRadius.circular(
                                AppDimens.BORDER_RADIUS_10,
                              ),
                            ),
                            child: Text(
                              ReservationFormatUtils.getStatusText(
                                  reservation.displayDate),
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: AppFonts.bold,
                                fontFamily: AppFonts.primaryFontFamily,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimens.PADDING_8),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
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
                  const SizedBox(height: AppDimens.PADDING_16),
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
                  const SizedBox(height: AppDimens.PADDING_12),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.PADDING_12),
                    decoration: BoxDecoration(
                      color: reservation.typeColor.withOpacity(0.2),
                      border: Border.all(width: 2, color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(
                        AppDimens.BORDER_RADIUS_12,
                      ),
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
