import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationDetailPage extends StatelessWidget {
  final Reservation reservation;
  const ReservationDetailPage({super.key, required this.reservation});

  String _safeFormatDate(DateTime? date) =>
      date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Non spécifiée';
  String _safeFormatTime(TimeOfDay? time) => time != null
      ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
      : 'Non spécifiée';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final establishmentName = reservation.establishmentName.isNotEmpty
        ? reservation.establishmentName
        : 'Commerce inconnu';
    final total = reservation.totalAmount.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomOtherAppBar(title: 'Détails de la réservation'),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppDimens.appPadding,
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    _buildHeaderCard(context, primaryColor, establishmentName),
                    const SizedBox(height: 16),
                    _buildInfoCard(context, 'Informations générales', [
                      _buildRow(
                        context,
                        'Commerce',
                        establishmentName,
                        icon: Icons.store,
                      ),
                      _buildRow(
                        context,
                        'Type',
                        reservation.typeDisplayName,
                        icon: Icons.category,
                      ),
                      _buildRow(
                        context,
                        'Nom',
                        reservation.customerName.isNotEmpty
                            ? reservation.customerName
                            : 'Non renseigné',
                        icon: Icons.person,
                      ),
                      _buildRow(
                        context,
                        'Téléphone',
                        reservation.phoneNumber.isNotEmpty
                            ? reservation.phoneNumber
                            : 'Non renseigné',
                        icon: Icons.phone,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    if (reservation.type == 'restaurant')
                      _buildInfoCard(context, 'Détails de la table', [
                        _buildRow(
                          context,
                          'Table',
                          reservation.tableNumber ?? 'Non spécifiée',
                          icon: Icons.table_restaurant,
                        ),
                        _buildRow(
                          context,
                          'Date',
                          _safeFormatDate(reservation.date),
                          icon: Icons.calendar_today,
                        ),
                        _buildRow(
                          context,
                          'Heure',
                          _safeFormatTime(reservation.time),
                          icon: Icons.access_time,
                        ),
                        _buildRow(
                          context,
                          'Personnes',
                          '${reservation.numberOfPeople ?? 0}',
                          icon: Icons.people,
                        ),
                      ]),
                    if (reservation.type == 'hotel')
                      _buildInfoCard(context, 'Détails de l\'hôtel', [
                        _buildRow(
                          context,
                          'Chambre',
                          reservation.roomType ?? 'Non spécifiée',
                          icon: Icons.king_bed,
                        ),
                        _buildRow(
                          context,
                          'Arrivée',
                          _safeFormatDate(reservation.checkInDate),
                          icon: Icons.calendar_today,
                        ),
                        _buildRow(
                          context,
                          'Départ',
                          _safeFormatDate(reservation.checkOutDate),
                          icon: Icons.calendar_today,
                        ),
                        _buildRow(
                          context,
                          'Chambres',
                          '${reservation.numberOfRooms ?? 1}',
                          icon: Icons.hotel,
                        ),
                        _buildRow(
                          context,
                          'Personnes',
                          '${reservation.numberOfGuests ?? 1}',
                          icon: Icons.people,
                        ),
                      ]),
                    if (reservation.type == 'car_rental')
                      _buildInfoCard(context, 'Détails de la location', [
                        _buildRow(
                          context,
                          'Véhicule',
                          reservation.vehicleType ?? 'Non spécifié',
                          icon: Icons.directions_car,
                        ),
                        _buildRow(
                          context,
                          'Début',
                          _safeFormatDate(reservation.rentalStartDate),
                          icon: Icons.calendar_today,
                        ),
                        _buildRow(
                          context,
                          'Fin',
                          _safeFormatDate(reservation.rentalEndDate),
                          icon: Icons.calendar_today,
                        ),
                      ]),
                    if (reservation.type == 'travel')
                      _buildInfoCard(context, 'Détails du voyage', [
                        _buildRow(
                          context,
                          'Destination',
                          reservation.destination ?? 'Non spécifiée',
                          icon: Icons.location_on,
                        ),
                        _buildRow(
                          context,
                          'Passagers',
                          '${reservation.numberOfPassengers ?? 1}',
                          icon: Icons.people,
                        ),
                      ]),
                    if (reservation.type == 'spa')
                      _buildInfoCard(context, 'Détails du spa', [
                        _buildRow(
                          context,
                          'Soin',
                          reservation.treatmentType ?? 'Non spécifié',
                          icon: Icons.spa,
                        ),
                        _buildRow(
                          context,
                          'Date',
                          _safeFormatDate(reservation.appointmentDate),
                          icon: Icons.calendar_today,
                        ),
                        _buildRow(
                          context,
                          'Thérapeute',
                          reservation.therapistName ?? 'Non spécifié',
                          icon: Icons.person_pin,
                        ),
                      ]),
                    if (reservation.type == 'cinema')
                      _buildInfoCard(context, 'Détails du cinéma', [
                        _buildRow(
                          context,
                          'Film',
                          reservation.movieTitle ?? 'Non spécifié',
                          icon: Icons.movie,
                        ),
                        _buildRow(
                          context,
                          'Séance',
                          _safeFormatDate(reservation.showtime),
                          icon: Icons.calendar_today,
                        ),
                        _buildRow(
                          context,
                          'Places',
                          '${reservation.numberOfTickets ?? 0}',
                          icon: Icons.confirmation_number,
                        ),
                      ]),
                    if (reservation.type == 'toursime')
                      _buildInfoCard(context, 'Détails du tourisme', [
                        _buildRow(
                          context,
                          'Activité',
                          reservation.activitiName ?? 'Non spécifiée',
                          icon: Icons.tour,
                        ),
                        _buildRow(
                          context,
                          'Date',
                          _safeFormatDate(reservation.day),
                          icon: Icons.calendar_today,
                        ),
                        _buildRow(
                          context,
                          'Participants',
                          '${reservation.numberOfPassengers ?? 1}',
                          icon: Icons.people,
                        ),
                      ]),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              _buildTotalCard(context, primaryColor, total),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    Color primaryColor,
    String establishmentName,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
            blurRadius: 7,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(width: 2.5, color: reservation.typeColor(context)),
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 50,
              color: reservation.typeColor(context),
            ),
            const SizedBox(height: 10),
            Text(
              establishmentName,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: reservation.typeColor(context),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Réservation du ${DateFormat('dd/MM/yyyy à HH:mm').format(reservation.reservationDate)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge!),
            const Divider(thickness: 1, height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(
    BuildContext context,
    Color primaryColor,
    String total,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: reservation.typeColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: reservation.typeColor(context), width: 2.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: Theme.of(context).textTheme.bodyLarge!),
          Text(
            '\$$total',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: reservation.typeColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
