import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
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
              fontFamily: 'Poppins',
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
              fontFamily: 'Poppins',
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
          _buildDetailRow('Arrivée', _safeFormatDate(reservation.checkInDate)),
          _buildDetailRow('Départ', _safeFormatDate(reservation.checkOutDate)),
          _buildDetailRow('Chambres', '${reservation.numberOfRooms ?? 1}'),
          _buildDetailRow('Personnes', '${reservation.numberOfGuests ?? 1}'),
        ];
      case 'restaurant':
        return [
          _buildDetailRow('Table', reservation.tableNumber ?? 'Non spécifiée'),
          _buildDetailRow('Étage', reservation.floor ?? 'Non spécifié'),
          _buildDetailRow('Date', _safeFormatDate(reservation.date)),
          _buildDetailRow('Heure', _safeFormatTime(reservation.time)),
          _buildDetailRow('Personnes', '${reservation.numberOfPeople ?? 1}'),
        ];
      case 'car_rental':
        return [
          _buildDetailRow('Véhicule', reservation.vehicleType ?? 'Non spécifié'),
          _buildDetailRow('Début', _safeFormatDate(reservation.rentalStartDate)),
          _buildDetailRow('Fin', _safeFormatDate(reservation.rentalEndDate)),
          _buildDetailRow('Durée', '${reservation.rentalDays ?? 0} jours'),
          _buildDetailRow('Chauffeur', reservation.withDriver == true ? 'Oui' : 'Non'),
          _buildDetailRow('Assurance', reservation.includeInsurance == true ? 'Incluse' : 'Optionnelle'),
          _buildDetailRow('Livraison', reservation.needDelivery == true ? 'Oui' : 'Non'),
        ];
      case 'travel':
        return [
          _buildDetailRow('Destination', reservation.destination ?? 'Non spécifiée'),
          _buildDetailRow('Départ', _safeFormatDate(reservation.displayDate)),
          _buildDetailRow('Heure', reservation.departureTime ?? 'Non spécifiée'),
          _buildDetailRow('Passagers', '${reservation.numberOfPassengers ?? 1}'),
        ];
      case 'spa':
        List<Widget> details = [];
        // Informations générales
        details.add(_buildDetailRow('Date', _safeFormatDate(reservation.appointmentDate)));
        details.add(_buildDetailRow('Heure',
            reservation.appointmentDate != null
                ? '${reservation.appointmentDate!.hour.toString().padLeft(2, '0')}:${reservation.appointmentDate!.minute.toString().padLeft(2, '0')}'
                : 'Non spécifiée'));
        if (reservation.therapistName != null) {
          details.add(_buildDetailRow('Thérapeute', reservation.therapistName!));
        }
        // Liste des soins sélectionnés
        if (reservation.selectedTreatments != null && reservation.selectedTreatments!.isNotEmpty) {
          details.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Soins réservés :', style: TextStyle(fontWeight: FontWeight.bold)),
          ));
          for (var treatment in reservation.selectedTreatments!) {
            details.add(Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(treatment['name'] ?? 'Soin inconnu'),
                  Text('${treatment['price']} €'),
                ],
              ),
            ));
          }
        } else {
          details.add(_buildDetailRow('Soin', reservation.treatmentType ?? 'Non spécifié'));
        }
        return details;
      case 'cinema':
        return [
          _buildDetailRow('Film', reservation.movieTitle ?? 'Non spécifié'),
          _buildDetailRow('Séance',
              reservation.showtime != null ? _formatDateTime(reservation.showtime!) : 'Non spécifiée'),
          _buildDetailRow('Type de billet', reservation.ticketType ?? 'Standard'),
          _buildDetailRow('Nombre de places', '${reservation.numberOfTickets ?? 1}'),
          if (reservation.seatNumbers != null && reservation.seatNumbers!.isNotEmpty)
            _buildDetailRow('Places', reservation.seatNumbers!),
        ];
      default:
        return [const SizedBox()];
    }
  }

  // ✅ Méthodes de formatage sécurisées
  String _safeFormatDate(DateTime? date) {
    if (date == null) return 'Non spécifiée';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _safeFormatTime(TimeOfDay? time) {
    if (time == null) return 'Non spécifiée';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Color _getStatusColor(DateTime reservationDate) {
    final now = DateTime.now();
    if (reservationDate.isBefore(now)) return Colors.grey;
    if (reservationDate.difference(now).inDays <= 1) return Colors.orange;
    return Colors.green;
  }

  String _getStatusText(DateTime reservationDate) {
    final now = DateTime.now();
    if (reservationDate.isBefore(now)) return 'Passée';
    if (reservationDate.difference(now).inDays <= 1) return 'Bientôt';
    return 'À venir';
  }
}

String _formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}