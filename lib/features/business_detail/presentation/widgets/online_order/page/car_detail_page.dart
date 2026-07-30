import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/order/data/models/vehicle_model.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/car_customer_form.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/car_date_range_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/car_image_header.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/car_options_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/car_price_summary.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/car_reservation_button.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/car_vehicle_header.dart';

class CarDetailPage extends StatefulWidget {
  final String businessId;
  final String? businessName;
  final Vehicle vehicle;

  const CarDetailPage({
    super.key,
    required this.businessId,
    this.businessName,
    required this.vehicle,
  });

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  final _reservationService = ReservationApiService();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _withDriver = false;
  bool _includeInsurance = false;
  bool _needDelivery = false;
  late TextEditingController _customerNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateTotalPrice() {
    if (_startDate == null || _endDate == null) return 0;
    int rentalDays = _endDate!.difference(_startDate!).inDays + 1;
    double total = rentalDays * widget.vehicle.dailyPrice;
    if (_withDriver) total += rentalDays * 50;
    if (_includeInsurance) total += rentalDays * 30;
    if (_needDelivery) total += 100;
    return total;
  }

  int _getRentalDays() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  Future<void> _submitReservation() async {
    if (SessionService.instance.currentUser == null) {
      showAuthRequiredCard(
        context,
        message: 'Connectez-vous pour réserver ce véhicule.',
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      _showSnackBar('Veuillez sélectionner les dates', AppColors.error);
      return;
    }
    if (_customerNameController.text.isEmpty) {
      _showSnackBar('Veuillez entrer votre nom', AppColors.error);
      return;
    }
    if (_phoneNumberController.text.isEmpty) {
      _showSnackBar('Veuillez entrer votre téléphone', AppColors.error);
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showSnackBar(
        'La date de fin doit être après la date de début',
        AppColors.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rentalDays = _getRentalDays();
      final totalAmount = _calculateTotalPrice();

      final details = {
        'vehicle_id': widget.vehicle.id,
        'vehicle_type': widget.vehicle.name,
        'rental_start_date': _startDate!.toIso8601String(),
        'rental_end_date': _endDate!.toIso8601String(),
        'rental_days': rentalDays,
        'with_driver': _withDriver,
        'include_insurance': _includeInsurance,
        'need_delivery': _needDelivery,
        'customer_name': _customerNameController.text,
        'phone': _phoneNumberController.text,
        'notes': _notesController.text,
      };

      await _reservationService.createReservation(
        businessId: widget.businessId,
        type: 'car_rental',
        reservationDate: DateTime.now(),
        totalAmount: totalAmount,
        details: details,
        establishmentName: widget.businessName,
      );

      if (mounted) {
        _showSnackBar(
          '✅ Réservation enregistrée avec succès!',
          AppColors.success,
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Erreur: ${e.toString()}', AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(date)) _endDate = null;
        } else {
          _endDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.background),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.vehicle.name,
          style: TextStyle(color: AppColors.background),
        ),
        elevation: 0,
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarImageHeader(imageUrl: widget.vehicle.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarVehicleHeader(
                    name: widget.vehicle.name,
                    type: widget.vehicle.type,
                    dailyPrice: widget.vehicle.dailyPrice,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  CarDateRangeSection(
                    startDate: _startDate,
                    endDate: _endDate,
                    rentalDays: _getRentalDays(),
                    onSelectStartDate: () => _selectDate(true),
                    onSelectEndDate: () => _selectDate(false),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  CarOptionsSection(
                    withDriver: _withDriver,
                    includeInsurance: _includeInsurance,
                    needDelivery: _needDelivery,
                    onWithDriverChanged: (v) =>
                        setState(() => _withDriver = v ?? false),
                    onIncludeInsuranceChanged: (v) =>
                        setState(() => _includeInsurance = v ?? false),
                    onNeedDeliveryChanged: (v) =>
                        setState(() => _needDelivery = v ?? false),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  CarCustomerForm(
                    nameController: _customerNameController,
                    phoneController: _phoneNumberController,
                    notesController: _notesController,
                  ),
                  const SizedBox(height: 24),
                  CarPriceSummary(
                    dailyPrice: widget.vehicle.dailyPrice,
                    rentalDays: _getRentalDays(),
                    withDriver: _withDriver,
                    includeInsurance: _includeInsurance,
                    needDelivery: _needDelivery,
                    totalPrice: _calculateTotalPrice(),
                  ),
                  const SizedBox(height: 24),
                  CarReservationButton(
                    isLoading: _isLoading,
                    onPressed: _submitReservation,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
