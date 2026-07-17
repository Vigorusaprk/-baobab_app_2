import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/spa_reservation_modal/spa_modal_chrome.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/spa_reservation_modal/spa_modal_pages.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/spa_reservation_modal/spa_reservation_helpers.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/spa_reservation_modal/spa_reservation_data.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showSpaReservationModal(BuildContext context, Business business) {
  final bloc = context.read<BusinessDetailBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => BlocProvider.value(
      value: bloc,
      child: SpaReservationModal(business: business),
    ),
  );
}

class SpaReservationModal extends StatefulWidget {
  final Business business;
  const SpaReservationModal({Key? key, required this.business}) : super(key: key);

  @override
  State<SpaReservationModal> createState() => _SpaReservationModalState();
}

class _SpaReservationModalState extends State<SpaReservationModal> {
  final PageController _pageController = PageController();
  final SpaReservationData _data = SpaReservationData();
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
    if (_currentPage == 0 && _data.selectedTreatments.isEmpty) {
      _showSnackBar('Veuillez sélectionner au moins un soin');
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

  bool _validateStep2() {
    return _fullNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _data.appointmentDate != null &&
        _data.appointmentTime != null;
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating
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

  Future<TimeOfDay?> _showTimePicker() async {
    return await showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  Future<void> _saveReservation() async {
    final sessionUser = SessionService.instance.currentUser;
    if (sessionUser == null) {
      _showSnackBar('Veuillez vous connecter');
      return;
    }
    final userId = sessionUser.id;

    setState(() => _isLoading = true);
    try {
      final treatments = _getTreatmentsList();
      final totalAmount = _data.calculateTotal(treatments);
      final selectedTreatmentsWithPrices = _data.getSelectedTreatmentsWithPrices(treatments);
      final appointmentDateTime = DateTime(
        _data.appointmentDate!.year,
        _data.appointmentDate!.month,
        _data.appointmentDate!.day,
        _data.appointmentTime!.hour,
        _data.appointmentTime!.minute,
      );

      final reservation = Reservation(
        id: '',
        businessId: widget.business.id,
        userId: userId,
        type: 'spa',
        reservationDate: DateTime.now(),
        createdAt: DateTime.now(),
        totalAmount: totalAmount,
        details: {
          'customer_name': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'appointment_date': appointmentDateTime.toIso8601String(),
          'selected_treatments': selectedTreatmentsWithPrices,
          'therapist_name': _data.selectedTherapist,
          'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          'establishment_name': widget.business.name,
        },
      );

      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      if (!mounted) return;
      _showSnackBar('Réservation confirmée !', isSuccess: true);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erreur : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getTreatmentsList() => getSpaTreatmentsList(widget.business);

  List<String> _getTherapistNames() => getSpaTherapistNames(widget.business);

  void _toggleTreatment(String name) {
    setState(() {
      if (_data.selectedTreatments.contains(name)) {
        _data.selectedTreatments.remove(name);
      } else {
        _data.selectedTreatments.add(name);
      }
    });
  }

  String _getPageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0: return 'Choisir vos soins';
      case 1: return 'Informations';
      case 2: return 'Récapitulatif';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 360;
        final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;
        final double titleFontSize = isSmallScreen ? 18.0 : 20.0;
        final treatments = _getTreatmentsList();

        return Container(
          height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.85 : 0.9),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              SpaModalHeader(
                isSmallScreen: isSmallScreen,
                titleFontSize: titleFontSize,
                title: _getPageTitle(_currentPage),
                businessName: widget.business.name,
                showBack: _currentPage > 0,
                onBack: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                onClose: () => Navigator.of(context).pop(),
              ),
              const Divider(height: 1, color: Colors.grey),
              SpaModalProgressIndicator(isSmallScreen: isSmallScreen, currentPage: _currentPage),
              const SizedBox(height: 16),
              Expanded(
                child: SpaModalPages(
                  pageController: _pageController,
                  isSmallScreen: isSmallScreen,
                  horizontalPadding: horizontalPadding,
                  treatments: treatments,
                  selectedTreatments: _data.selectedTreatments,
                  totalAmount: _data.calculateTotal(treatments),
                  onToggleTreatment: _toggleTreatment,
                  onSelectTreatmentNext: _data.selectedTreatments.isNotEmpty ? _nextPage : null,
                  fullNameController: _fullNameController,
                  phoneController: _phoneController,
                  notesController: _notesController,
                  appointmentDate: _data.appointmentDate,
                  appointmentTime: _data.appointmentTime,
                  onPickDate: () async {
                    final selected = await _showDatePicker();
                    setState(() => _data.appointmentDate = selected);
                  },
                  onPickTime: () async {
                    final selected = await _showTimePicker();
                    setState(() => _data.appointmentTime = selected);
                  },
                  therapistNames: _getTherapistNames(),
                  selectedTherapist: _data.selectedTherapist,
                  onSelectTherapist: (name) => setState(() => _data.selectedTherapist = name),
                  onFieldChanged: () => setState(() {}),
                  canContinue: _validateStep2(),
                  onContinue: _nextPage,
                  businessName: widget.business.name,
                  selectedTreatmentsWithPrices: _data.getSelectedTreatmentsWithPrices(treatments),
                  isLoading: _isLoading,
                  onConfirm: _saveReservation,
                  onEditInfo: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
