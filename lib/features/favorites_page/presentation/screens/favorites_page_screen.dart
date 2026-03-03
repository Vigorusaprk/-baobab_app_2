import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/reservation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FavoritesPageScreen extends StatefulWidget {
  const FavoritesPageScreen({super.key});

  @override
  State<FavoritesPageScreen> createState() => _FavoritesPageScreenState();
}

class _FavoritesPageScreenState extends State<FavoritesPageScreen> {
  List<Reservation> _allReservations = [];
  List<Reservation> _displayedReservations = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final reservations = await ReservationService.getReservations();
    setState(() {
      _allReservations = reservations;
      _displayedReservations = reservations;
      _isLoading = false;
    });
  }

  void _filterReservations(String type) {
    setState(() {
      _selectedFilter = type;
      if (type == 'Tous') {
        _displayedReservations = _allReservations;
      } else if (type == 'Hôtels') {
        _displayedReservations = _allReservations.where((r) => r.reservationType == 'hotel').toList();
      } else if (type == 'Restaurants') {
        _displayedReservations = _allReservations.where((r) => r.reservationType == 'restaurant').toList();
      } else if (type == 'Locations') {
        _displayedReservations = _allReservations.where((r) => r.reservationType == 'car_rental').toList();
      } else if (type == 'Voyages') {
        _displayedReservations = _allReservations.where((r) => r.reservationType == 'travel').toList();
      } else if (type == 'Spas') {
        _displayedReservations = _allReservations.where((r) => r.reservationType == 'spa').toList();
      }
    });
  }

  Future<void> _deleteReservation(String id) async {
    await ReservationService.deleteReservation(id);
    _loadReservations();
  }

  void _showReservationDetails(Reservation reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => _buildReservationDetailSheet(reservation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECTION "MES RÉSERVATIONS"
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/calendar-date-svgrepo-com (1).svg',
                  height: 35,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppDimens.PADDING_12),
                Text(
                  'Mes Réservations',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFontFamily,
                    fontSize: 24,
                    fontWeight: AppFonts.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (_allReservations.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.PADDING_12,
                      vertical: AppDimens.PADDING_6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_16),
                    ),
                    child: Text(
                      '${_allReservations.length}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: AppFonts.semiBold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // FILTRES
          if (_allReservations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.PADDING_16,
                vertical: AppDimens.PADDING_8,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tous', () => _filterReservations('Tous')),
                    const SizedBox(width: 8),
                    _buildFilterChip('Hôtels', () => _filterReservations('Hôtels')),
                    const SizedBox(width: 8),
                    _buildFilterChip('Restaurants', () => _filterReservations('Restaurants')),
                    const SizedBox(width: 8),
                    _buildFilterChip('Locations', () => _filterReservations('Locations')),
                    const SizedBox(width: 8),
                    _buildFilterChip('Voyages', () => _filterReservations('Voyages')),
                    const SizedBox(width: 8),
                    _buildFilterChip('Spas', () => _filterReservations('Spas')),
                  ],
                ),
              ),
            ),

          // CONTENU PRINCIPAL
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.BORDER_RADIUS_30),
                  topRight: Radius.circular(AppDimens.BORDER_RADIUS_30),
                ),
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.PADDING_16,
          vertical: AppDimens.PADDING_8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20),
          border: isSelected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: AppFonts.medium,
            fontFamily: AppFonts.primaryFontFamily,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_allReservations.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // STATISTIQUES
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.PADDING_16),
          margin: const EdgeInsets.fromLTRB(
            AppDimens.PADDING_16,
            AppDimens.PADDING_16,
            AppDimens.PADDING_16,
            AppDimens.PADDING_8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', _allReservations.length.toString()),
              _buildStatItem(
                'Hôtels',
                _allReservations.where((r) => r.reservationType == 'hotel').length.toString(),
              ),
              _buildStatItem(
                'Restaurants',
                _allReservations.where((r) => r.reservationType == 'restaurant').length.toString(),
              ),
              _buildStatItem(
                'Locations',
                _allReservations.where((r) => r.reservationType == 'car_rental').length.toString(),
              ),
              _buildStatItem(
                'Voyages',
                _allReservations.where((r) => r.reservationType == 'travel').length.toString(),
              ),
              _buildStatItem(
                'Spas',
                _allReservations.where((r) => r.reservationType == 'spa').length.toString(),
              ),
            ],
          ),
        ),

        // INDICATEUR DE FILTRE
        if (_selectedFilter != 'Tous' && _displayedReservations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.PADDING_16),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Filtré par : $_selectedFilter (${_displayedReservations.length} réservation${_displayedReservations.length > 1 ? 's' : ''})',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontFamily: AppFonts.primaryFontFamily,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _filterReservations('Tous'),
                  child: Text(
                    'Tout afficher',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontFamily: AppFonts.primaryFontFamily,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // LISTE DES RÉSERVATIONS
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadReservations,
            color: AppColors.primary,
            child: _displayedReservations.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.PADDING_32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.filter_alt_off,
                      size: 64,
                      color: AppColors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppDimens.PADDING_16),
                    Text(
                      'Aucune réservation trouvée',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: AppFonts.semiBold,
                        color: AppColors.textPrimary,
                        fontFamily: AppFonts.primaryFontFamily,
                      ),
                    ),
                    const SizedBox(height: AppDimens.PADDING_8),
                    Text(
                      'Aucune réservation ne correspond au filtre "$_selectedFilter"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                        fontFamily: AppFonts.primaryFontFamily,
                      ),
                    ),
                    const SizedBox(height: AppDimens.PADDING_24),
                    ElevatedButton(
                      onPressed: () => _filterReservations('Tous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.PADDING_24,
                          vertical: AppDimens.PADDING_12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12),
                        ),
                      ),
                      child: const Text('Afficher toutes les réservations'),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.PADDING_16,
                AppDimens.PADDING_8,
                AppDimens.PADDING_16,
                AppDimens.PADDING_16,
              ),
              itemCount: _displayedReservations.length,
              itemBuilder: (context, index) {
                final reservation = _displayedReservations[index];
                return _buildReservationCard(reservation);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.PADDING_32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/calendar_check_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.svg',
              color: AppColors.grey.withOpacity(0.5),
              height: 120,
              width: 120,
            ),
            const SizedBox(height: AppDimens.PADDING_24),
            Text(
              'Aucune réservation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: AppFonts.semiBold,
                color: AppColors.textPrimary,
                fontFamily: AppFonts.primaryFontFamily,
              ),
            ),
            const SizedBox(height: AppDimens.PADDING_12),
            Text(
              'Vos réservations futures apparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey,
                fontFamily: AppFonts.primaryFontFamily,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.PADDING_32),
            ElevatedButton(
              onPressed: _loadReservations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.PADDING_24,
                  vertical: AppDimens.PADDING_12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12),
                ),
              ),
              child: const Text('Actualiser'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: AppFonts.bold,
            color: AppColors.primary,
            fontFamily: AppFonts.primaryFontFamily,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.grey,
            fontFamily: AppFonts.primaryFontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.PADDING_16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => _showReservationDetails(reservation),
          borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.PADDING_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête de la carte
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: reservation.typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12),
                      ),
                      child: Icon(
                        reservation.typeIcon,
                        color: reservation.typeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDimens.PADDING_16),

                    // Informations principales
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
                                  color: reservation.typeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_8),
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
                                  _getReservationSubtitle(reservation),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey,
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

                    // Statut et actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.PADDING_10,
                            vertical: AppDimens.PADDING_5,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(reservation.displayDate),
                            borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_10),
                          ),
                          child: Text(
                            _getStatusText(reservation.displayDate),
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
                            color: AppColors.grey,
                            size: 20,
                          ),
                          onPressed: () => _showDeleteDialog(reservation),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.PADDING_16),

                // Détails spécifiques au type
                if (reservation.reservationType == 'hotel')
                  _buildHotelReservationDetails(reservation)
                else if (reservation.reservationType == 'restaurant')
                  _buildRestaurantReservationDetails(reservation)
                else if (reservation.reservationType == 'car_rental')
                    _buildCarRentalReservationDetails(reservation)
                  else if (reservation.reservationType == 'travel')
                      _buildTravelReservationDetails(reservation)
                    else if (reservation.reservationType == 'spa')
                        _buildSpaReservationDetails(reservation),

                const SizedBox(height: AppDimens.PADDING_12),

                // Montant total
                Container(
                  padding: const EdgeInsets.all(AppDimens.PADDING_12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: AppFonts.semiBold,
                          color: AppColors.success,
                          fontFamily: AppFonts.primaryFontFamily,
                        ),
                      ),
                      Text(
                        '\$${reservation.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: AppFonts.bold,
                          color: AppColors.success,
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
  }

  String _getReservationSubtitle(Reservation reservation) {
    if (reservation.reservationType == 'hotel') {
      return '${_formatDate(reservation.checkInDate!)} - ${_formatDate(reservation.checkOutDate!)}';
    } else if (reservation.reservationType == 'car_rental') {
      return '${_formatDate(reservation.rentalStartDate!)} - ${_formatDate(reservation.rentalEndDate!)}';
    } else if (reservation.reservationType == 'travel') {
      return '${reservation.destination ?? "Destination inconnue"} • ${_formatDate(reservation.displayDate)}';
    } else if (reservation.reservationType == 'spa') {
      return '${reservation.treatmentType ?? "Soin"} • ${_formatDate(reservation.appointmentDate!)}';
    } else {
      return '${_formatDate(reservation.date!)} • ${_formatTime(reservation.time!)}';
    }
  }

  // ========== DÉTAILS SPÉCIFIQUES ==========

  Widget _buildHotelReservationDetails(Reservation reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.king_bed, reservation.roomType ?? 'Non spécifié'),
        _buildDetailRow(Icons.person, reservation.customerName),
        _buildDetailRow(Icons.phone, reservation.phoneNumber),
        _buildDetailRow(
          Icons.calendar_today,
          'Du ${_formatDate(reservation.checkInDate!)} au ${_formatDate(reservation.checkOutDate!)}',
        ),
        _buildDetailRow(
          Icons.people,
          '${reservation.numberOfGuests ?? 0} invité${reservation.numberOfGuests! > 1 ? 's' : ''} • ${reservation.numberOfRooms ?? 0} chambre${reservation.numberOfRooms! > 1 ? 's' : ''}',
        ),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildRestaurantReservationDetails(Reservation reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.person, reservation.customerName),
        _buildDetailRow(Icons.phone, reservation.phoneNumber),
        _buildDetailRow(
          Icons.calendar_today,
          '${_formatDate(reservation.date!)} à ${_formatTime(reservation.time!)}',
        ),
        _buildDetailRow(
          Icons.people,
          '${reservation.numberOfPeople ?? 0} personne${reservation.numberOfPeople! > 1 ? 's' : ''}',
        ),
        _buildDetailRow(
          Icons.table_restaurant,
          'Table ${reservation.tableNumber ?? '?'} - ${reservation.floor ?? '?'}',
        ),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildCarRentalReservationDetails(Reservation reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.directions_car, reservation.vehicleType ?? 'Non spécifié'),
        _buildDetailRow(Icons.person, reservation.customerName),
        _buildDetailRow(Icons.phone, reservation.phoneNumber),
        _buildDetailRow(
          Icons.calendar_today,
          'Du ${_formatDate(reservation.rentalStartDate!)} au ${_formatDate(reservation.rentalEndDate!)}',
        ),
        _buildDetailRow(
          Icons.timer,
          '${reservation.rentalDays ?? 0} jour${reservation.rentalDays! > 1 ? 's' : ''} de location',
        ),
        if (reservation.withDriver == true)
          _buildDetailRow(Icons.person_pin, 'Avec chauffeur'),
        if (reservation.includeInsurance == false)
          _buildDetailRow(Icons.security, 'Assurance optionnelle'),
        if (reservation.needDelivery == true)
          _buildDetailRow(Icons.delivery_dining, 'Livraison incluse'),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildTravelReservationDetails(Reservation reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.location_on, reservation.destination ?? 'Destination non spécifiée'),
        _buildDetailRow(Icons.person, reservation.customerName),
        _buildDetailRow(Icons.phone, reservation.phoneNumber),
        _buildDetailRow(
          Icons.calendar_today,
          'Départ : ${_formatDate(reservation.displayDate)}',
        ),
        _buildDetailRow(
          Icons.access_time,
          reservation.departureTime ?? 'Heure non spécifiée',
        ),
        _buildDetailRow(
          Icons.people,
          '${reservation.numberOfPassengers ?? 1} passager${reservation.numberOfPassengers! > 1 ? 's' : ''}',
        ),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildSpaReservationDetails(Reservation reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.spa, reservation.treatmentType ?? 'Soin non spécifié'),
        _buildDetailRow(Icons.person, reservation.customerName),
        _buildDetailRow(Icons.phone, reservation.phoneNumber),
        _buildDetailRow(
          Icons.calendar_today,
          _formatDate(reservation.appointmentDate!),
        ),
        _buildDetailRow(
          Icons.access_time,
          '${reservation.appointmentDate!.hour.toString().padLeft(2, '0')}:${reservation.appointmentDate!.minute.toString().padLeft(2, '0')}',
        ),
        if (reservation.therapistName != null)
          _buildDetailRow(Icons.person_pin, 'Thérapeute: ${reservation.therapistName}'),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.PADDING_4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.grey,
          ),
          const SizedBox(width: AppDimens.PADDING_12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontFamily: AppFonts.primaryFontFamily,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ========== BOTTOM SHEET DE DÉTAILS ==========

  Widget _buildReservationDetailSheet(Reservation reservation) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.PADDING_24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.BORDER_RADIUS_30),
          topRight: Radius.circular(AppDimens.BORDER_RADIUS_30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.PADDING_24),
          Row(
            children: [
              Icon(
                reservation.typeIcon,
                color: reservation.typeColor,
                size: 24,
              ),
              const SizedBox(width: AppDimens.PADDING_12),
              Expanded(
                child: Text(
                  'Détails de la réservation - ${reservation.typeDisplayName}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: AppFonts.bold,
                    color: reservation.typeColor,
                    fontFamily: AppFonts.primaryFontFamily,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.PADDING_24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Carte informations générales
                  _buildDetailCard(
                    'Informations ${reservation.typeDisplayName}',
                    [
                      _buildDetailItem('Établissement', reservation.establishmentName),
                      if (reservation.reservationType == 'restaurant') ...[
                        _buildDetailItem('Table', '${reservation.tableNumber ?? '?'} (${reservation.floor ?? '?'})'),
                      ] else if (reservation.reservationType == 'hotel') ...[
                        _buildDetailItem('Type de chambre', reservation.roomType ?? 'Non spécifié'),
                      ] else if (reservation.reservationType == 'car_rental') ...[
                        _buildDetailItem('Type de véhicule', reservation.vehicleType ?? 'Non spécifié'),
                      ] else if (reservation.reservationType == 'travel') ...[
                        _buildDetailItem('Destination', reservation.destination ?? 'Non spécifiée'),
                      ] else if (reservation.reservationType == 'spa') ...[
                        _buildDetailItem('Soin', reservation.treatmentType ?? 'Non spécifié'),
                      ],
                    ],
                  ),

                  // Carte informations client
                  _buildDetailCard('Informations Client', [
                    _buildDetailItem('Nom', reservation.customerName),
                    _buildDetailItem('Téléphone', reservation.phoneNumber),
                  ]),

                  // Carte détails réservation
                  _buildDetailCard('Détails Réservation', [
                    if (reservation.reservationType == 'restaurant') ...[
                      _buildDetailItem('Date', _formatDate(reservation.date!)),
                      _buildDetailItem('Heure', _formatTime(reservation.time!)),
                      _buildDetailItem('Nombre de personnes', reservation.numberOfPeople.toString()),
                    ] else if (reservation.reservationType == 'hotel') ...[
                      _buildDetailItem('Arrivée', _formatDate(reservation.checkInDate!)),
                      _buildDetailItem('Départ', _formatDate(reservation.checkOutDate!)),
                      _buildDetailItem('Invités', reservation.numberOfGuests.toString()),
                      _buildDetailItem('Chambres', reservation.numberOfRooms.toString()),
                    ] else if (reservation.reservationType == 'car_rental') ...[
                      _buildDetailItem('Début', _formatDate(reservation.rentalStartDate!)),
                      _buildDetailItem('Fin', _formatDate(reservation.rentalEndDate!)),
                      _buildDetailItem('Durée', '${reservation.rentalDays} jours'),
                      _buildDetailItem('Avec chauffeur', reservation.withDriver == true ? 'Oui' : 'Non'),
                      _buildDetailItem('Assurance', reservation.includeInsurance == true ? 'Incluse' : 'Optionnelle'),
                      _buildDetailItem('Livraison', reservation.needDelivery == true ? 'Oui' : 'Non'),
                    ] else if (reservation.reservationType == 'travel') ...[
                      _buildDetailItem('Date de départ', _formatDate(reservation.displayDate)),
                      _buildDetailItem('Heure de départ', reservation.departureTime ?? 'Non spécifiée'),
                      _buildDetailItem('Passagers', reservation.numberOfPassengers.toString()),
                    ] else if (reservation.reservationType == 'spa') ...[
                      _buildDetailItem('Date', _formatDate(reservation.appointmentDate!)),
                      _buildDetailItem('Heure',
                          '${reservation.appointmentDate!.hour.toString().padLeft(2, '0')}:${reservation.appointmentDate!.minute.toString().padLeft(2, '0')}'),
                      if (reservation.therapistName != null)
                        _buildDetailItem('Thérapeute', reservation.therapistName!),
                    ],
                    _buildDetailItem('Statut', _getStatusText(reservation.displayDate)),
                  ]),

                  if (reservation.notes != null && reservation.notes!.isNotEmpty)
                    _buildDetailCard('Notes', [
                      _buildDetailItem('Commentaires', reservation.notes!),
                    ]),

                  // Carte paiement
                  _buildDetailCard('Paiement', [
                    _buildDetailItem('Total', '\$${reservation.totalAmount.toStringAsFixed(2)}'),
                    _buildDetailItem('Réservé le', _formatDateTime(reservation.reservationDate)),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.PADDING_20),

          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12),
                    ),
                  ),
                  child: Text(
                    'Fermer',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.PADDING_12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteDialog(reservation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12),
                    ),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimens.PADDING_16),
      padding: const EdgeInsets.all(AppDimens.PADDING_16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_16),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: AppFonts.bold,
              fontFamily: AppFonts.primaryFontFamily,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimens.PADDING_12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.PADDING_6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label :',
              style: TextStyle(
                fontWeight: AppFonts.medium,
                color: AppColors.grey,
                fontSize: 14,
                fontFamily: AppFonts.primaryFontFamily,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: AppFonts.regular,
                fontSize: 14,
                fontFamily: AppFonts.primaryFontFamily,
                color: AppColors.textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20),
        ),
        title: Text(
          'Annuler la réservation',
          style: TextStyle(
            fontFamily: AppFonts.primaryFontFamily,
            fontWeight: AppFonts.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir annuler la réservation chez ${reservation.establishmentName} ?',
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppFonts.primaryFontFamily,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Conserver'),
          ),
          TextButton(
            onPressed: () {
              _deleteReservation(reservation.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  // ========== FORMATAGE ==========

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(DateTime reservationDate) {
    final now = DateTime.now();
    if (reservationDate.isBefore(now)) {
      return AppColors.grey; // Passée
    } else if (reservationDate.difference(now).inDays <= 1) {
      return AppColors.warning; // Bientôt
    } else {
      return AppColors.success; // À venir
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