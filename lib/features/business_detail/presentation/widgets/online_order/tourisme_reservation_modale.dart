import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'tourisme_reservation_modale/tourism_reservation_data.dart';
import 'tourisme_reservation_modale/select_activities_page.dart';
import 'tourisme_reservation_modale/information_page.dart';
import 'tourisme_reservation_modale/summary_page.dart';
import 'tourisme_reservation_modale/modal_header.dart';

export 'tourisme_reservation_modale/tourism_reservation_data.dart';

void showTourismReservationModal(BuildContext context, Business business) {
  final bloc = context.read<BusinessDetailBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => BlocProvider.value(
      value: bloc,
      child: TourismReservationModal(business: business),
    ),
  );
}

class TourismReservationModal extends StatefulWidget {
  final Business business;
  const TourismReservationModal({Key? key, required this.business}) : super(key: key);

  @override
  State<TourismReservationModal> createState() => _TourismReservationModalState();
}

class _TourismReservationModalState extends State<TourismReservationModal> {
  final PageController _pageController = PageController();
  final TourismReservationData _data = TourismReservationData();
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
    if (_currentPage == 0 && _data.selectedActivities.isEmpty) {
      _showSnackBar('Veuillez sélectionner au moins une activité');
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
        _data.activityDate != null;
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<DateTime?> _showDatePicker() async {
    final BuildContext rootContext = Navigator.of(context).context;
    return await showDatePicker(
      context: rootContext,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      locale: const Locale('fr', 'FR'),
    );
  }

  Future<void> _saveReservation() async {
    final sessionUser = SessionService.instance.currentUser;
    if (sessionUser == null) {
      _showSnackBar('Veuillez vous connecter');
      return;
    }
    if (_fullNameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty || _data.activityDate == null) {
      _showSnackBar('Veuillez remplir tous les champs obligatoires');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final activities = widget.business.specificData['activities'] as List? ?? [];
      final totalAmount = _data.calculateTotal(activities);
      final selectedActivitiesWithPrices = _data.getSelectedActivitiesWithPrices(activities);

      final reservation = Reservation(
        id: '',
        businessId: widget.business.id,
        userId: sessionUser.id,
        type: 'tourisme',
        reservationDate: _data.activityDate!,
        createdAt: DateTime.now(),
        totalAmount: totalAmount,
        details: {
          'customer_name': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          'day': _data.activityDate!.toIso8601String(),
          'number_of_passengers': _data.numberOfParticipants,
          'selected_activities': selectedActivitiesWithPrices,
          'establishment_name': widget.business.name,
        },
      );

      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      if (!mounted) return;
      _showSnackBar('Réservation confirmée !', isSuccess: true);
      Navigator.pop(context);
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
        final activities = widget.business.specificData['activities'] as List? ?? [];

        return Container(
          height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.85 : 0.9),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              TourismModalHeader(
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
                    SelectActivitiesPage(
                      isSmallScreen: isSmallScreen,
                      horizontalPadding: horizontalPadding,
                      activities: activities,
                      selectedActivities: _data.selectedActivities,
                      totalAmount: _data.calculateTotal(activities),
                      onToggleActivity: (name) {
                        setState(() {
                          if (_data.selectedActivities.contains(name)) {
                            _data.selectedActivities.remove(name);
                          } else {
                            _data.selectedActivities.add(name);
                          }
                        });
                      },
                      onNext: _data.selectedActivities.isNotEmpty ? _nextPage : null,
                    ),
                    InformationPage(
                      isSmallScreen: isSmallScreen,
                      horizontalPadding: horizontalPadding,
                      fullNameController: _fullNameController,
                      phoneController: _phoneController,
                      notesController: _notesController,
                      activityDate: _data.activityDate,
                      onPickDate: () async {
                        final selected = await _showDatePicker();
                        setState(() => _data.activityDate = selected);
                      },
                      numberOfParticipants: _data.numberOfParticipants,
                      onParticipantsChanged: (value) => setState(() => _data.numberOfParticipants = value),
                      canContinue: _validateStep2(),
                      onNext: _nextPage,
                      onFieldChanged: () => setState(() {}),
                    ),
                    SummaryPage(
                      isSmallScreen: isSmallScreen,
                      horizontalPadding: horizontalPadding,
                      businessName: widget.business.name,
                      fullName: _fullNameController.text,
                      phone: _phoneController.text,
                      activityDate: _data.activityDate,
                      numberOfParticipants: _data.numberOfParticipants,
                      notes: _notesController.text,
                      selectedActivitiesWithPrices: _data.getSelectedActivitiesWithPrices(activities),
                      totalAmount: _data.calculateTotal(activities),
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
