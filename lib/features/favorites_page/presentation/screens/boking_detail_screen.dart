import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/reservation_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:go_router/go_router.dart';

class ReservationDetailPage extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailPage({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Détails de la réservation'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildDetailCard(
              'Informations générales',
              [
                _buildDetailRow('Établissement', reservation.establishmentName),
                _buildDetailRow('Type', reservation.typeDisplayName),
                _buildDetailRow('Date de réservation',
                    DateFormat('dd/MM/yyyy HH:mm').format(reservation.reservationDate)),
                _buildDetailRow('Statut', _getStatusText(reservation.displayDate),
                    valueColor: _getStatusColor(reservation.displayDate)),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'Informations client',
              [
                _buildDetailRow('Nom', reservation.customerName),
                _buildDetailRow('Téléphone', reservation.phoneNumber),
                if (reservation.notes != null && reservation.notes!.isNotEmpty)
                  _buildDetailRow('Notes', reservation.notes!),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'Détails spécifiques',
              _buildSpecificDetails(),
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'Paiement',
              [
                _buildDetailRow('Total', '\$${reservation.totalAmount.toStringAsFixed(2)}',
                    isBold: true, valueColor: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: reservation.typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: reservation.typeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: reservation.typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              reservation.typeIcon,
              color: reservation.typeColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.establishmentName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reservation.typeDisplayName,
                  style: TextStyle(
                    color: reservation.typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins'
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: valueColor,
              fontFamily: 'Poppins'
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpecificDetails() {
    switch (reservation.reservationType) {
      case 'hotel':
        return [
          _buildDetailRow('Type de chambre', reservation.roomType ?? 'Non spécifié'),
          _buildDetailRow('Arrivée', _formatDate(reservation.checkInDate!)),
          _buildDetailRow('Départ', _formatDate(reservation.checkOutDate!)),
          _buildDetailRow('Chambres', '${reservation.numberOfRooms ?? 1}'),
          _buildDetailRow('Personnes', '${reservation.numberOfGuests ?? 1}'),
        ];
      case 'restaurant':
        return [
          _buildDetailRow('Table', reservation.tableNumber ?? 'Non spécifiée'),
          _buildDetailRow('Étage', reservation.floor ?? 'Non spécifié'),
          _buildDetailRow('Date', _formatDate(reservation.date!)),
          _buildDetailRow('Heure', _formatTime(reservation.time!)),
          _buildDetailRow('Personnes', '${reservation.numberOfPeople ?? 1}'),
        ];
      case 'car_rental':
        return [
          _buildDetailRow('Véhicule', reservation.vehicleType ?? 'Non spécifié'),
          _buildDetailRow('Début', _formatDate(reservation.rentalStartDate!)),
          _buildDetailRow('Fin', _formatDate(reservation.rentalEndDate!)),
          _buildDetailRow('Durée', '${reservation.rentalDays} jours'),
          _buildDetailRow('Chauffeur', reservation.withDriver == true ? 'Oui' : 'Non'),
          _buildDetailRow('Assurance', reservation.includeInsurance == true ? 'Incluse' : 'Optionnelle'),
          _buildDetailRow('Livraison', reservation.needDelivery == true ? 'Oui' : 'Non'),
        ];
      case 'travel':
        return [
          _buildDetailRow('Destination', reservation.destination ?? 'Non spécifiée'),
          _buildDetailRow('Départ', _formatDate(reservation.displayDate)),
          _buildDetailRow('Heure', reservation.departureTime ?? 'Non spécifiée'),
          _buildDetailRow('Passagers', '${reservation.numberOfPassengers ?? 1}'),
        ];
      case 'spa':
        return [
          _buildDetailRow('Soin', reservation.treatmentType ?? 'Non spécifié'),
          _buildDetailRow('Date', _formatDate(reservation.appointmentDate!)),
          _buildDetailRow('Heure',
              '${reservation.appointmentDate!.hour.toString().padLeft(2, '0')}:${reservation.appointmentDate!.minute.toString().padLeft(2, '0')}'),
          if (reservation.therapistName != null)
            _buildDetailRow('Thérapeute', reservation.therapistName!),
        ];
      default:
        return [const SizedBox()];
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(DateTime reservationDate) {
    final now = DateTime.now();
    if (reservationDate.isBefore(now)) {
      return Colors.grey;
    } else if (reservationDate.difference(now).inDays <= 1) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getStatusText(DateTime reservationDate) {
    final now = DateTime.now();
    if (reservationDate.isBefore(now)) {
      return 'Passée';
    } else if (reservationDate.difference(now).inDays <= 1) {
      return 'Bientôt';
    } else {
      return 'À venir';
    }
  }
}