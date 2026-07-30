import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'travel_agency_modal/travel_reservation_data.dart';
import 'travel_agency_modal/modal_header.dart';
import 'travel_agency_modal/select_destination_page.dart';
import 'travel_agency_modal/information_page.dart';
import 'travel_agency_modal/summary_page.dart';

export 'travel_agency_modal/travel_reservation_data.dart';

void showTravelReservationModal(BuildContext context, Business business) {
  final bloc = context.read<BusinessDetailBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (modalContext) => BlocProvider.value(
      value: bloc,
      child: TravelReservationModal(business: business),
    ),
  );
}

class TravelReservationModal extends StatefulWidget {
  final Business business;
  const TravelReservationModal({Key? key, required this.business})
    : super(key: key);

  @override
  State<TravelReservationModal> createState() => _TravelReservationModalState();
}

class _TravelReservationModalState extends State<TravelReservationModal> {
  final PageController _pageController = PageController();
  final TravelReservationData _data = TravelReservationData();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        final next = _pageController.page?.round() ?? 0;
        if (next != _currentPage) {
          setState(() => _currentPage = next);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _data.destination == null) {
      _showSnackBar('Veuillez choisir une destination');
      return;
    }
    if (_currentPage == 1 && !_validateStep2()) {
      _showSnackBar('Veuillez remplir tous les champs obligatoires');
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  bool _validateStep2() {
    return _fullNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _data.departureDate != null;
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<DateTime?> _showDatePicker() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
  }

  Future<void> _saveReservation() async {
    final sessionUser = SessionService.instance.currentUser;
    if (sessionUser == null) {
      showAuthRequiredCard(
        context,
        message: 'Connectez-vous pour réserver ce voyage.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final totalAmount = _data.calculateTotal();

      final reservation = Reservation(
        id: '',
        businessId: widget.business.id,
        userId: sessionUser.id,
        type: 'voyage',
        reservationDate: DateTime.now(),
        createdAt: DateTime.now(),
        totalAmount: totalAmount,
        details: {
          'customer_name': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'destination': _data.destination,
          'departure_date': _data.departureDate!.toIso8601String(),
          'number_of_passengers': _data.numberOfPassengers,
          'notes': _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          'establishment_name': widget.business.name,
        },
      );

      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      if (!mounted) return;
      _showSnackBar('Voyage réservé avec succès !', isSuccess: true);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erreur : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 360;
        final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;
        final double titleFontSize = isSmallScreen ? 18.0 : 20.0;

        return Container(
          height:
              MediaQuery.of(context).size.height * (isSmallScreen ? 0.85 : 0.9),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              TravelModalHeader(
                isSmallScreen: isSmallScreen,
                titleFontSize: titleFontSize,
                currentPage: _currentPage,
                businessName: widget.business.name,
                onBack: _previousPage,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SelectDestinationPage(
                      isSmallScreen: isSmallScreen,
                      horizontalPadding: horizontalPadding,
                      destination: _data.destination,
                      onDestinationChanged: (v) =>
                          setState(() => _data.destination = v),
                      onNext: _data.destination != null ? _nextPage : null,
                    ),
                    InformationPage(
                      isSmallScreen: isSmallScreen,
                      horizontalPadding: horizontalPadding,
                      fullNameController: _fullNameController,
                      phoneController: _phoneController,
                      notesController: _notesController,
                      departureDate: _data.departureDate,
                      onPickDate: () async {
                        final selected = await _showDatePicker();
                        setState(() => _data.departureDate = selected);
                      },
                      numberOfPassengers: _data.numberOfPassengers,
                      onPassengersChanged: (value) =>
                          setState(() => _data.numberOfPassengers = value),
                      canContinue: _validateStep2(),
                      onNext: _nextPage,
                      onFieldChanged: () => setState(() {}),
                    ),
                    SummaryPage(
                      isSmallScreen: isSmallScreen,
                      horizontalPadding: horizontalPadding,
                      fullName: _fullNameController.text,
                      phone: _phoneController.text,
                      destination: _data.destination,
                      departureDate: _data.departureDate,
                      numberOfPassengers: _data.numberOfPassengers,
                      notes: _notesController.text,
                      totalAmount: _data.calculateTotal(),
                      isLoading: _isLoading,
                      onBack: _previousPage,
                      onConfirm: _saveReservation,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
