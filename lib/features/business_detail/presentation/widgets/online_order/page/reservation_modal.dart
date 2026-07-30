import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/reservation_modal/reservation_modal_pages.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/reservation_modal/reservation_modal_header.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/reservation_modal/reservation_progress_indicator.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ReservationData {
  String? selectedTable;
  String? fullName;
  String? phoneNumber;
  DateTime? date;
  TimeOfDay? time;
  int? numberOfPeople;
  String? notes;

  double subtotal = 206.45;
  double tax = 20.6;
  double get grandTotal => subtotal + tax;
}

void showRestaurantReservationModal(BuildContext context, Business business) {
  final isRestaurant =
      business.type.name == 'restaurant' || business.type.name == 'restaurent';
  final canReserve = business.specificData['canReserve'] == true;

  if (!isRestaurant || !canReserve) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'La réservation n\'est pas disponible pour ${business.name}',
        ),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) {
      return Localizations(
        locale: const Locale('fr', 'FR'),
        delegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: ReservationModal(business: business),
      );
    },
  );
}

class ReservationModal extends StatefulWidget {
  final Business business;

  const ReservationModal({Key? key, required this.business}) : super(key: key);

  @override
  _ReservationModalState createState() => _ReservationModalState();
}

class _ReservationModalState extends State<ReservationModal> {
  final PageController _pageController = PageController();
  final ReservationData _data = ReservationData();
  final List<String> _floors = [
    'Rez-de-chaussée',
    '1er Étage',
    '2ème Étage',
    'Terrasse',
  ];
  String _selectedFloor = 'Rez-de-chaussée';
  String? _selectedTable;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _peopleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.page == 0 && _selectedTable == null) {
      _showSnackBar('Veuillez sélectionner une table');
      return;
    }
    if (_pageController.page == 1 && !_validateStep2()) {
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
        _data.date != null &&
        _data.time != null &&
        _peopleController.text.isNotEmpty;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<DateTime?> _showDatePicker() async {
    final BuildContext rootContext = Navigator.of(context).context;
    final DateTime? picked = await showDatePicker(
      context: rootContext,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      locale: const Locale('fr', 'FR'),
    );
    return picked;
  }

  Future<TimeOfDay?> _showTimePicker() async {
    final BuildContext rootContext = Navigator.of(context).context;
    final TimeOfDay? picked = await showTimePicker(
      context: rootContext,
      initialTime: TimeOfDay.now(),
    );
    return picked;
  }

  Future<void> _saveReservation() async {
    setState(() => _isLoading = true);

    final sessionUser = SessionService.instance.currentUser;
    if (sessionUser == null) {
      setState(() => _isLoading = false);
      showAuthRequiredCard(
        context,
        message: 'Connectez-vous pour réserver cette table.',
      );
      return;
    }

    // --- CORRECTION ICI : Vérification de la nullité ---
    final selectedDate = _data.date;
    final selectedTime = _data.time;

    if (selectedDate == null || selectedTime == null) {
      _showSnackBar('Veuillez sélectionner une date et une heure');
      setState(() => _isLoading = false);
      return;
    }

    final userId = sessionUser.id;

    // Maintenant, Dart sait que ces valeurs ne sont pas nulles
    final fullDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final reservation = Reservation(
      id: '',
      businessId: widget.business.id,
      userId: userId,
      type: 'restaurant',
      reservationDate: fullDateTime,
      totalAmount: _data.grandTotal,
      details: {
        "table_number": _data.selectedTable ?? "Non spécifiée",
        "floor": _selectedFloor,
        "customer_name": _fullNameController.text,
        "phone_number": _phoneController.text,
        "number_of_people": int.tryParse(_peopleController.text) ?? 1,
        "date": selectedDate.toIso8601String(),
        "time": "${selectedTime.hour}:${selectedTime.minute}",
        "notes": _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
        "establishment_name": widget.business.name,
      },
      createdAt: DateTime.now(),
    );

    try {
      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      Navigator.pop(context);
      _showSnackBar('Réservation confirmée !');
    } catch (e) {
      print("Erreur lors de la réservation: $e");
      _showSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          ReservationModalHeader(
            title: _getPageTitle(
              _pageController.hasClients ? _pageController.page!.round() : 0,
            ),
            businessName: widget.business.name,
            showBack: _pageController.hasClients && _pageController.page! > 0,
            onBack: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            onClose: () => Navigator.of(context).pop(),
          ),
          const Divider(height: 1, color: AppColors.textSecondary),

          ReservationProgressIndicator(
            currentPage: _pageController.hasClients
                ? _pageController.page!.round()
                : 0,
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ReservationModalPages(
              pageController: _pageController,
              floors: _floors,
              selectedFloor: _selectedFloor,
              onFloorSelected: (floor) =>
                  setState(() => _selectedFloor = floor),
              selectedTable: _selectedTable,
              onTableSelected: (table) => setState(() {
                _selectedTable = table;
                _data.selectedTable = table;
              }),
              onSelectTableNext: _selectedTable != null ? _nextPage : null,
              fullNameController: _fullNameController,
              phoneController: _phoneController,
              peopleController: _peopleController,
              notesController: _notesController,
              date: _data.date,
              time: _data.time,
              onPickDate: () async {
                final selectedDate = await _showDatePicker();
                setState(() {
                  _data.date = selectedDate;
                });
              },
              onPickTime: () async {
                final selectedTime = await _showTimePicker();
                setState(() {
                  _data.time = selectedTime;
                });
              },
              onFieldChanged: () => setState(() {}),
              canContinue: _validateStep2(),
              onContinue: _nextPage,
              businessName: widget.business.name,
              subtotal: _data.subtotal,
              tax: _data.tax,
              grandTotal: _data.grandTotal,
              isLoading: _isLoading,
              onConfirm: _saveReservation,
              onEditInfo: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'Sélection de table';
      case 1:
        return 'Informations';
      case 2:
        return 'Récapitulatif';
      default:
        return '';
    }
  }
}
