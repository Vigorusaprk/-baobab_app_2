import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
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

    // Valeurs de secours pour éviter les affichages vides
    final establishmentName = reservation.establishmentName.isNotEmpty
        ? reservation.establishmentName
        : 'Établissement inconnu';
    final total = reservation.totalAmount.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Détails de la réservation'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(primaryColor, establishmentName),
          const SizedBox(height: 16),
          _buildInfoCard('Informations générales', [
            _buildRow('Établissement', establishmentName, icon: Icons.store),
            _buildRow('Type', reservation.typeDisplayName, icon: Icons.category),
            _buildRow('Nom', reservation.customerName.isNotEmpty ? reservation.customerName : 'Non renseigné',
                icon: Icons.person),
            _buildRow('Téléphone',
                reservation.phoneNumber.isNotEmpty ? reservation.phoneNumber : 'Non renseigné',
                icon: Icons.phone),
          ]),
          const SizedBox(height: 16),
          if (reservation.reservationType == 'restaurant')
            _buildInfoCard('Détails du restaurant', [
              _buildRow('Table', reservation.tableNumber ?? 'Non spécifiée', icon: Icons.table_restaurant),
              _buildRow('Date', _safeFormatDate(reservation.date), icon: Icons.calendar_today),
              _buildRow('Heure', _safeFormatTime(reservation.time), icon: Icons.access_time),
              _buildRow('Personnes', '${reservation.numberOfPeople ?? 0}', icon: Icons.people),
            ]),
          if (reservation.reservationType == 'hotel')
            _buildInfoCard('Détails de l\'hôtel', [
              _buildRow('Chambre', reservation.roomType ?? 'Non spécifiée', icon: Icons.king_bed),
              _buildRow('Arrivée', _safeFormatDate(reservation.checkInDate), icon: Icons.calendar_today),
              _buildRow('Départ', _safeFormatDate(reservation.checkOutDate), icon: Icons.calendar_today),
              _buildRow('Chambres', '${reservation.numberOfRooms ?? 1}', icon: Icons.hotel),
              _buildRow('Personnes', '${reservation.numberOfGuests ?? 1}', icon: Icons.people),
            ]),
          if (reservation.reservationType == 'car_rental')
            _buildInfoCard('Détails de la location', [
              _buildRow('Véhicule', reservation.vehicleType ?? 'Non spécifié', icon: Icons.directions_car),
              _buildRow('Début', _safeFormatDate(reservation.rentalStartDate), icon: Icons.calendar_today),
              _buildRow('Fin', _safeFormatDate(reservation.rentalEndDate), icon: Icons.calendar_today),
            ]),
          const SizedBox(height: 16),
          _buildTotalCard(primaryColor, total),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Color primaryColor, String establishmentName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [reservation.typeColor, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.receipt_long, size: 50, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              establishmentName,
              style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Réservation du ${DateFormat('dd/MM/yyyy à HH:mm').format(reservation.reservationDate)}',
              style: const TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(thickness: 1, height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
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

  Widget _buildTotalCard(Color primaryColor, String total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: reservation.typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: reservation.typeColor, width: 2.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            '\$$total',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}