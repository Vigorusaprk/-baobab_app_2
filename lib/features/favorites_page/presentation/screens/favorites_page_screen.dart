import 'dart:ui';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/main/presentation/widgets/main_background.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';

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
  String _userId = "";
  late final ReservationApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ReservationApiService();
    _selectedFilter = 'Tous'; // Force le filtre "Tous"
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserId());
  }

  Future<void> _loadUserId() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _userId = authState.user.id;
      await _loadReservations();
    } else {
      context.go('/login');
    }
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    try {
      final reservations = await _apiService.getReservations(userId: _userId);
      print('📦 Nombre total de réservations : ${reservations.length}');
      for (var r in reservations) {
        print('  - Type: ${r.reservationType}, Établissement: ${r.establishmentName}');
      }
      setState(() {
        _allReservations = reservations;
        _displayedReservations = reservations;
      });
    } catch (e) {
      print('❌ Erreur chargement : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
      } else if (type == 'Cinémas') {
        _displayedReservations = _allReservations.where((r) => r.reservationType == 'cinema').toList();
      } else if (type == 'Tourisme') {
        _displayedReservations = _allReservations.where((r) => r.reservationType == 'toursime').toList();
      }
    });
  }

  Future<void> _deleteReservation(String id) async {
    try {
      await _apiService.deleteReservation(id, userId: _userId);
      await _loadReservations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur suppression : $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showDeleteDialog(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20)),
        title: Text('Annuler la réservation', style: TextStyle(fontFamily: AppFonts.primaryFontFamily, fontWeight: AppFonts.bold, color: AppColors.textPrimary)),
        content: Text('Êtes-vous sûr de vouloir annuler la réservation chez ${reservation.establishmentName} ?',
            style: TextStyle(fontSize: 14, fontFamily: AppFonts.primaryFontFamily, color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: AppColors.primary), child: const Text('Conserver')),
          TextButton(onPressed: () { _deleteReservation(reservation.id); Navigator.pop(context); }, style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Annuler')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              // En-tête
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/calendar-date-svgrepo-com (1).svg', height: 35,
                        colorFilter: ColorFilter.mode(AppColors.scaffoldBackground, BlendMode.srcIn)),
                    const SizedBox(width: AppDimens.PADDING_12),
                    Text('Mes Réservations', style: TextStyle(fontFamily: AppFonts.primaryFontFamily, fontSize: 24, fontWeight: AppFonts.bold, color: AppColors.scaffoldBackground)),
                    const Spacer(),
                    if (_allReservations.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimens.PADDING_12, vertical: AppDimens.PADDING_6),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_16)),
                        child: Text('${_allReservations.length}', style: TextStyle(color: AppColors.primary, fontWeight: AppFonts.semiBold, fontSize: 14, fontFamily: 'Poppins')),
                      ),
                  ],
                ),
              ),
              // Filtres
              if (_allReservations.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.PADDING_16, vertical: AppDimens.PADDING_8),
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
                        const SizedBox(width: 8),
                        _buildFilterChip('Cinémas', () => _filterReservations('Cinémas')),
                        const SizedBox(width: 8),
                        _buildFilterChip('Tourisme', () => _filterReservations('Tourisme')),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.PADDING_16, vertical: AppDimens.PADDING_8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20),
          border: isSelected ? Border.all(color: AppColors.primary) : null,
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: AppFonts.medium, fontFamily: AppFonts.primaryFontFamily, color: isSelected ? AppColors.white : AppColors.textPrimary)),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_allReservations.isEmpty) return _buildEmptyState();
    return Column(
      children: [
        if (_selectedFilter != 'Tous' && _displayedReservations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.PADDING_16),
            child: Row(
              children: [
                Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Flexible(child: Text('Filtré par : $_selectedFilter (${_displayedReservations.length} réservation${_displayedReservations.length > 1 ? 's' : ''})', style: TextStyle(fontSize: 12, color: AppColors.primary, fontFamily: AppFonts.primaryFontFamily))),
                const Spacer(),
                TextButton(onPressed: () => _filterReservations('Tous'), child: Text('Tout afficher', style: TextStyle(fontSize: 12, color: AppColors.primary, fontFamily: AppFonts.primaryFontFamily, decoration: TextDecoration.underline))),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadReservations,
            color: AppColors.primary,
            child: _displayedReservations.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_alt_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune réservation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.scaffoldBackground,
                              fontFamily: AppFonts.primaryFontFamily,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune réservation ne correspond au filtre "$_selectedFilter"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: AppFonts.primaryFontFamily,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _filterReservations('Tous'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Voir toutes les réservations',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppDimens.PADDING_16, AppDimens.PADDING_8, AppDimens.PADDING_16, 100),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/calendar-date-svgrepo-com (1).svg',
                      height: 80,
                      colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Aucune réservation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.scaffoldBackground,
                      fontFamily: AppFonts.primaryFontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vous n\'avez pas encore passé de réservation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: AppFonts.primaryFontFamily,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explorez nos hôtels, restaurants et services pour réserver',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontFamily: AppFonts.primaryFontFamily,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.storefront_outlined, size: 20),
                      label: const Text(
                        'Découvrir les commerces',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.scaffoldBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    try {
      print('🏨 Construction carte pour type: ${reservation.reservationType}, nom: ${reservation.establishmentName}');
      return Container(
        margin: const EdgeInsets.only(bottom: AppDimens.PADDING_16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.pushNamed('reservationDetail', extra: reservation),
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
                        width: 50, height: 50,
                        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [reservation.typeColor.withOpacity(0.2), reservation.typeColor.withOpacity(0.05)]), borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12)),
                        child: Icon(reservation.typeIcon, color: reservation.typeColor, size: 24),
                      ),
                      const SizedBox(width: AppDimens.PADDING_16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reservation.establishmentName, style: TextStyle(fontSize: 18, fontWeight: AppFonts.bold, fontFamily: AppFonts.primaryFontFamily, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: AppDimens.PADDING_4),
                            Row(
                              children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: AppDimens.PADDING_8, vertical: AppDimens.PADDING_4), decoration: BoxDecoration(color: reservation.typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_8)), child: Text(reservation.typeDisplayName, style: TextStyle(color: reservation.typeColor, fontSize: 12, fontWeight: AppFonts.bold, fontFamily: AppFonts.primaryFontFamily))),
                                const SizedBox(width: AppDimens.PADDING_8),
                                Expanded(child: Text(_getReservationSubtitle(reservation), style: TextStyle(fontSize: 14, color: AppColors.grey, fontFamily: AppFonts.primaryFontFamily), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: AppDimens.PADDING_10, vertical: AppDimens.PADDING_5), decoration: BoxDecoration(color: _getStatusColor(reservation.displayDate), borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_10)), child: Text(_getStatusText(reservation.displayDate), style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: AppFonts.bold, fontFamily: AppFonts.primaryFontFamily))),
                          const SizedBox(height: AppDimens.PADDING_8),
                          IconButton(icon: Icon(Icons.delete_outline, color: AppColors.grey, size: 20), onPressed: () => _showDeleteDialog(reservation), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.PADDING_16),
                  // Détails spécifiques
                  if (reservation.reservationType == 'hotel')
                    _buildHotelReservationDetails(reservation)
                  else if (reservation.reservationType == 'restaurant')
                    _buildRestaurantReservationDetails(reservation)
                  else if (reservation.reservationType == 'car_rental')
                      _buildCarRentalReservationDetails(reservation)
                    else if (reservation.reservationType == 'travel')
                        _buildTravelReservationDetails(reservation)
                      else if (reservation.reservationType == 'spa')
                          _buildSpaReservationDetails(reservation)
                        else if (reservation.reservationType == 'cinema')
                            _buildCinemaReservationDetails(reservation)
                          else if (reservation.reservationType == 'toursime')
                              _buildTourismReservationDetails(reservation),
                  const SizedBox(height: AppDimens.PADDING_12),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.PADDING_12),
                    decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.05)]), borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: TextStyle(fontSize: 16, fontWeight: AppFonts.semiBold, color: AppColors.success, fontFamily: AppFonts.primaryFontFamily)),
                        Text('\$${reservation.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: AppFonts.bold, color: AppColors.success, fontFamily: AppFonts.primaryFontFamily)),
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
      return Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Erreur d’affichage : $e')));
    }
  }

  // ========== Détails par type ==========

  Widget _buildHotelReservationDetails(Reservation reservation) {
    print('🏨 Construction détails hôtel pour ${reservation.establishmentName}');
    return Column(
      children: [
        _buildDetailRow(Icons.king_bed, reservation.roomType ?? 'Non spécifié'),
        _buildDetailRow(Icons.person, reservation.customerName.isNotEmpty ? reservation.customerName : 'Non renseigné'),
        _buildDetailRow(Icons.phone, reservation.phoneNumber.isNotEmpty ? reservation.phoneNumber : 'Non renseigné'),
        _buildDetailRow(Icons.calendar_today, 'Du ${_safeFormatDate(reservation.checkInDate)} au ${_safeFormatDate(reservation.checkOutDate)}'),
        _buildDetailRow(Icons.people, '${reservation.numberOfGuests ?? 0} invité(s) • ${reservation.numberOfRooms ?? 0} chambre(s)'),
        if (reservation.notes != null && reservation.notes!.isNotEmpty) _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildRestaurantReservationDetails(Reservation reservation) {
    return Column(
      children: [
        _buildDetailRow(Icons.person, reservation.customerName.isNotEmpty ? reservation.customerName : 'Non renseigné'),
        _buildDetailRow(Icons.phone, reservation.phoneNumber.isNotEmpty ? reservation.phoneNumber : 'Non renseigné'),
        _buildDetailRow(Icons.calendar_today, '${_safeFormatDate(reservation.date)} à ${_safeFormatTime(reservation.time)}'),
        _buildDetailRow(Icons.people, '${reservation.numberOfPeople ?? 0} personne(s)'),
        _buildDetailRow(Icons.table_restaurant, 'Table ${reservation.tableNumber ?? '?'}'),
        if (reservation.notes != null && reservation.notes!.isNotEmpty) _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildCarRentalReservationDetails(Reservation reservation) {
    return Column(
      children: [
        _buildDetailRow(Icons.directions_car, reservation.vehicleType ?? 'Non spécifié'),
        _buildDetailRow(Icons.person, reservation.customerName.isNotEmpty ? reservation.customerName : 'Non renseigné'),
        _buildDetailRow(Icons.phone, reservation.phoneNumber.isNotEmpty ? reservation.phoneNumber : 'Non renseigné'),
        _buildDetailRow(Icons.calendar_today, 'Du ${_safeFormatDate(reservation.rentalStartDate)} au ${_safeFormatDate(reservation.rentalEndDate)}'),
        _buildDetailRow(Icons.timer, '${reservation.rentalDays ?? 0} jour(s)'),
        if (reservation.withDriver == true) _buildDetailRow(Icons.person_pin, 'Avec chauffeur'),
        if (reservation.includeInsurance == false) _buildDetailRow(Icons.security, 'Assurance optionnelle'),
        if (reservation.needDelivery == true) _buildDetailRow(Icons.delivery_dining, 'Livraison incluse'),
        if (reservation.notes != null && reservation.notes!.isNotEmpty) _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildTravelReservationDetails(Reservation reservation) {
    return Column(
      children: [
        _buildDetailRow(Icons.location_on, reservation.destination ?? 'Destination non spécifiée'),
        _buildDetailRow(Icons.person, reservation.customerName.isNotEmpty ? reservation.customerName : 'Non renseigné'),
        _buildDetailRow(Icons.phone, reservation.phoneNumber.isNotEmpty ? reservation.phoneNumber : 'Non renseigné'),
        _buildDetailRow(Icons.calendar_today, 'Départ : ${_safeFormatDate(reservation.displayDate)}'),
        _buildDetailRow(Icons.access_time, reservation.departureTime ?? 'Heure non spécifiée'),
        _buildDetailRow(Icons.people, '${reservation.numberOfPassengers ?? 1} passager(s)'),
        if (reservation.notes != null && reservation.notes!.isNotEmpty) _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildSpaReservationDetails(Reservation reservation) {
    return Column(
      children: [
        _buildDetailRow(Icons.spa, reservation.treatmentType ?? 'Soin non spécifié'),
        _buildDetailRow(Icons.person, reservation.customerName.isNotEmpty ? reservation.customerName : 'Non renseigné'),
        _buildDetailRow(Icons.phone, reservation.phoneNumber.isNotEmpty ? reservation.phoneNumber : 'Non renseigné'),
        _buildDetailRow(Icons.calendar_today, _safeFormatDate(reservation.appointmentDate)),
        _buildDetailRow(Icons.access_time, reservation.appointmentDate != null ? '${reservation.appointmentDate!.hour.toString().padLeft(2, '0')}:${reservation.appointmentDate!.minute.toString().padLeft(2, '0')}' : 'Non spécifiée'),
        if (reservation.therapistName != null) _buildDetailRow(Icons.person_pin, 'Thérapeute: ${reservation.therapistName}'),
        if (reservation.selectedTreatments != null && reservation.selectedTreatments!.isNotEmpty) ...[
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Soins réservés :', style: TextStyle(fontWeight: FontWeight.bold))),
          ...reservation.selectedTreatments!.map((treatment) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(treatment['name'] ?? 'Soin inconnu'), Text('${treatment['price']} €')]),
          )),
        ],
        if (reservation.notes != null && reservation.notes!.isNotEmpty) _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildCinemaReservationDetails(Reservation reservation) {
    return Column(
      children: [
        _buildDetailRow(Icons.movie, reservation.movieTitle ?? 'Film non spécifié'),
        _buildDetailRow(Icons.person, reservation.customerName.isNotEmpty ? reservation.customerName : 'Non renseigné'),
        _buildDetailRow(Icons.phone, reservation.phoneNumber.isNotEmpty ? reservation.phoneNumber : 'Non renseigné'),
        _buildDetailRow(Icons.calendar_today, _safeFormatDate(reservation.showtime)),
        _buildDetailRow(Icons.access_time, reservation.showtime != null ? '${reservation.showtime!.hour.toString().padLeft(2, '0')}:${reservation.showtime!.minute.toString().padLeft(2, '0')}' : 'Non spécifiée'),
        _buildDetailRow(Icons.confirmation_number, '${reservation.ticketType} x${reservation.numberOfTickets}'),
        if (reservation.seatNumbers != null && reservation.seatNumbers!.isNotEmpty) _buildDetailRow(Icons.airline_seat_recline_normal, 'Places : ${reservation.seatNumbers}'),
        if (reservation.notes != null && reservation.notes!.isNotEmpty) _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  Widget _buildTourismReservationDetails(Reservation reservation) {
    return Column(
      children: [
        _buildDetailRow(Icons.tour, reservation.activitiName ?? 'Activité non spécifiée'),
        _buildDetailRow(Icons.person, reservation.customerName.isNotEmpty ? reservation.customerName : 'Non renseigné'),
        _buildDetailRow(Icons.phone, reservation.phoneNumber.isNotEmpty ? reservation.phoneNumber : 'Non renseigné'),
        _buildDetailRow(Icons.calendar_today, _safeFormatDate(reservation.day)),
        _buildDetailRow(Icons.people, '${reservation.numberOfPassengers ?? 1} participant(s)'),
        if (reservation.selectedActivities != null && reservation.selectedActivities!.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Activités sélectionnées :', style: TextStyle(fontWeight: FontWeight.bold)),
          ...reservation.selectedActivities!.map((activity) => Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(activity['name'] ?? ''), Text('${activity['price']} €')]),
          )),
        ],
        if (reservation.notes != null && reservation.notes!.isNotEmpty) _buildDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }

  // ========== Utilitaires ==========
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.PADDING_4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey),
          const SizedBox(width: AppDimens.PADDING_12),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: AppColors.textPrimary, fontFamily: AppFonts.primaryFontFamily), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String _getReservationSubtitle(Reservation reservation) {
    if (reservation.reservationType == 'hotel') {
      final ci = reservation.checkInDate;
      final co = reservation.checkOutDate;
      if (ci != null && co != null) return '${_formatDate(ci)} - ${_formatDate(co)}';
      return 'Dates non spécifiées';
    } else if (reservation.reservationType == 'car_rental') {
      final sd = reservation.rentalStartDate;
      final ed = reservation.rentalEndDate;
      if (sd != null && ed != null) return '${_formatDate(sd)} - ${_formatDate(ed)}';
      return 'Dates non spécifiées';
    } else if (reservation.reservationType == 'travel') {
      return '${reservation.destination ?? "Destination inconnue"} • ${_safeFormatDate(reservation.displayDate)}';
    } else if (reservation.reservationType == 'spa') {
      return '${reservation.treatmentType ?? "Soin"} • ${_safeFormatDate(reservation.appointmentDate)}';
    } else if (reservation.reservationType == 'cinema') {
      return '${reservation.movieTitle ?? "Film"} • ${_safeFormatDate(reservation.showtime)}';
    } else if (reservation.reservationType == 'toursime') {
      return '${reservation.activitiName ?? "Activité"} • ${_safeFormatDate(reservation.day)}';
    } else {
      return '${_safeFormatDate(reservation.date)} • ${_safeFormatTime(reservation.time)}';
    }
  }

  String _safeFormatDate(DateTime? date) => date != null ? _formatDate(date) : 'Non spécifiée';
  String _safeFormatTime(TimeOfDay? time) => time != null ? _formatTime(time) : 'Non spécifiée';
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Color _getStatusColor(DateTime reservationDate) {
    final now = DateTime.now();
    if (reservationDate.isBefore(now)) return AppColors.grey;
    if (reservationDate.difference(now).inDays <= 1) return AppColors.warning;
    return AppColors.success;
  }

  String _getStatusText(DateTime reservationDate) {
    final now = DateTime.now();
    if (reservationDate.isBefore(now)) return 'Passée';
    if (reservationDate.difference(now).inDays <= 1) return 'Bientôt';
    return 'À venir';
  }
}