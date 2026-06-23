import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/features/order/data/models/vehicle_model.dart';

class CarDetailPage extends StatefulWidget {
  final String businessId;
  final Vehicle vehicle;

  const CarDetailPage({
    super.key,
    required this.businessId,
    required this.vehicle,
  });

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  final _reservationService = Injector.get<ReservationApiService>();

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

  Future<void> _submitReservation(String userId) async {
    if (_startDate == null || _endDate == null) {
      _showSnackBar('Veuillez sélectionner les dates', Colors.red);
      return;
    }
    if (_customerNameController.text.isEmpty) {
      _showSnackBar('Veuillez entrer votre nom', Colors.red);
      return;
    }
    if (_phoneNumberController.text.isEmpty) {
      _showSnackBar('Veuillez entrer votre téléphone', Colors.red);
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showSnackBar(
        'La date de fin doit être après la date de début',
        Colors.red,
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
      );

      if (mounted) {
        _showSnackBar('✅ Réservation enregistrée avec succès!', Colors.green);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Erreur: ${e.toString()}', Colors.red);
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
    final authState = context.watch<AuthBloc>().state;
    final isLoggedIn = authState is AuthenticatedState;
    final userId = isLoggedIn ? authState.user.id : null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.scaffoldBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.vehicle.name,
          style: TextStyle(color: AppColors.scaffoldBackground),
        ),
        elevation: 0,
        backgroundColor: AppColors.primaryLight,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: widget.vehicle.imageUrl.isNotEmpty
                  ? Image.network(
                widget.vehicle.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 100,
                    color: Colors.grey[600],
                  ),
                ),
              )
                  : Center(
                child: Icon(
                  Icons.directions_car,
                  size: 100,
                  color: Colors.grey[600],
                ),
              ),
            ),
            if (!isLoggedIn)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade100,
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Veuillez vous connecter pour réserver',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.vehicle.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.vehicle.type,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.vehicle.dailyPrice.toStringAsFixed(0)}€/jour',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'Dates de location',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Début',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _startDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : 'Sélectionner',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'Sélectionner',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_startDate != null && _endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        '→ ${_getRentalDays()} jour(s) de location',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3F51B5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'Options supplémentaires',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Avec chauffeur'),
                    subtitle: const Text('+50€/jour'),
                    value: _withDriver,
                    onChanged: (v) => setState(() => _withDriver = v ?? false),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Assurance complète'),
                    subtitle: const Text('+30€/jour'),
                    value: _includeInsurance,
                    onChanged: (v) =>
                        setState(() => _includeInsurance = v ?? false),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Livraison'),
                    subtitle: const Text('+100€ une fois'),
                    value: _needDelivery,
                    onChanged: (v) =>
                        setState(() => _needDelivery = v ?? false),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'Vos coordonnées',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customerNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom complet *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Téléphone *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Notes (optionnel)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Résumé',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tarif journalier × ${_getRentalDays()} jour(s)',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${(widget.vehicle.dailyPrice * _getRentalDays()).toStringAsFixed(2)}€',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (_withDriver) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Chauffeur',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${(50 * _getRentalDays()).toStringAsFixed(2)}€',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_includeInsurance) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Assurance',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${(30 * _getRentalDays()).toStringAsFixed(2)}€',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_needDelivery) ...[
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Livraison', style: TextStyle(fontSize: 12)),
                              Text('100.00€', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_calculateTotalPrice().toStringAsFixed(2)}€',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (!isLoggedIn || _isLoading)
                          ? null
                          : () => _submitReservation(userId!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Text(
                        'Réserver maintenant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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