import 'dart:async';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/main/presentation/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservation_filter_chips_row.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservation_empty_state.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservation_no_match_state.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservation_card.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservation_cancel_dialog.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservations_page_header.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservation_filter_banner.dart';

class FavoritesPageScreen extends StatefulWidget {
  const FavoritesPageScreen({super.key});

  @override
  State<FavoritesPageScreen> createState() => _FavoritesPageScreenState();
}

class _FavoritesPageScreenState extends State<FavoritesPageScreen> {
  List<Reservation> _allReservations = [];
  List<Reservation> _displayedReservations = [];
  bool _isLoading = true;
  bool _hasLoadedReservations = false;
  String _selectedFilter = 'Tous';
  String _userId = "";
  final ReservationApiService _apiService = ReservationApiService();
  StreamSubscription<AppSessionUser?>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _selectedFilter = 'Tous';
    _sessionSubscription = SessionService.instance.userChanges.listen((user) {
      if (user != null) {
        if (_userId != user.id || !_hasLoadedReservations) {
          _userId = user.id;
          _loadReservations();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserId());
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final user = SessionService.instance.currentUser;
    if (user != null) {
      _userId = user.id;
      await _loadReservations();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    try {
      final user = SessionService.instance.currentUser;
      if (user == null) {
        print('FavoritesPageScreen._loadReservations skipped: no authenticated user');
        return;
      }

      _userId = user.id;
      print('FavoritesPageScreen._loadReservations: userId=$_userId');

      final reservations = await _apiService.getReservations(userId: _userId);
      print('📦 Chargement réussi. Nombre de réservations reçues : ${reservations.length}');

      for (var r in reservations) {
        print('  - ID: ${r.id}, Type brut: "${r.type}", Établissement: ${r.establishmentName}');
      }

      if (mounted) {
        setState(() {
          _allReservations = reservations;
          _displayedReservations = reservations;
          _hasLoadedReservations = true;
        });
      }
    } catch (e) {
      print('❌ Erreur critique lors du chargement : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterReservations(String filterName) {
    setState(() {
      _selectedFilter = filterName;

      if (filterName == 'Tous') {
        _displayedReservations = _allReservations;
      } else {
        // Mapping des noms cliqués (labels) vers les types réels stockés dans Supabase
        // Attention : vérifiez bien l'orthographe dans votre base (ex: 'toursime' vs 'tourisme')
        final typeMap = {
          'Hôtels': 'hotel',
          'Restaurants': 'restaurant',
          'Locations': 'car_rental',
          'Voyages': 'travel',
          'Spas': 'spa',
          'Cinémas': 'cinema',
          'Tourisme': 'toursime',
        };

        final targetType = typeMap[filterName];

        _displayedReservations = _allReservations.where((r) {
          return r.type.toLowerCase() == targetType?.toLowerCase();
        }).toList();

        print('🔍 Filtrage pour $filterName (type cible: $targetType). '
            'Trouvés : ${_displayedReservations.length}');
      }
    });
  }

  Future<void> _deleteReservation(String id) async {
    try {
      await _apiService.deleteReservation(id, userId: _userId);
      await _loadReservations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur suppression : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(Reservation reservation) {
    showCancelReservationDialog(
      context,
      reservation,
      () => _deleteReservation(reservation.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return authBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
          children: [
            ReservationsPageHeader(reservationCount: _allReservations.length),
            if (_allReservations.isNotEmpty)
              ReservationFilterChipsRow(
                selectedFilter: _selectedFilter,
                onFilterSelected: _filterReservations,
              ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_allReservations.isEmpty) return const ReservationEmptyState();
    return Column(
      children: [
        if (_selectedFilter != 'Tous' && _displayedReservations.isNotEmpty)
          ReservationFilterBanner(
            selectedFilter: _selectedFilter,
            resultCount: _displayedReservations.length,
            onShowAll: () => _filterReservations('Tous'),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadReservations,
            color: AppColors.primary,
            child: _displayedReservations.isEmpty
                ? ReservationNoMatchState(
                    selectedFilter: _selectedFilter,
                    onShowAll: () => _filterReservations('Tous'),
                  )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.PADDING_16,
                AppDimens.PADDING_8,
                AppDimens.PADDING_16,
                100,
              ),
              itemCount: _displayedReservations.length,
              itemBuilder: (context, index) {
                final reservation = _displayedReservations[index];
                return ReservationCard(
                  reservation: reservation,
                  onDelete: () => _showDeleteDialog(reservation),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
