import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'reservation_service.dart';

class CarRentalData {
  String? selectedVehicleType;
  DateTime? rentalStartDate;
  DateTime? rentalEndDate;
  int get rentalDays {
    if (rentalStartDate != null && rentalEndDate != null) {
      final days = rentalEndDate!.difference(rentalStartDate!).inDays;
      return days < 1 ? 1 : days;
    }
    return 0;
  }
  bool withDriver = false;
  bool includeInsurance = true;
  bool needDelivery = false;

  double calculateTotal(List<dynamic> vehicleTypes) {
    if (selectedVehicleType == null) return 0.0;

    final selectedType = _findVehicleType(vehicleTypes, selectedVehicleType!);

    if (selectedType == null) return 0.0;

    final dailyPrice = (selectedType['dailyPrice'] as num?)?.toDouble() ?? 0.0;
    double total = dailyPrice * rentalDays;

    if (withDriver) total += 50.0 * rentalDays;
    if (needDelivery) total += 25.0;
    if (!includeInsurance) total += 15.0 * rentalDays;

    return total;
  }

  Map<String, dynamic>? _findVehicleType(List<dynamic> vehicleTypes, String typeName) {
    for (final type in vehicleTypes) {
      if (type is Map<String, dynamic> && type['type'] == typeName) {
        return type;
      }
    }
    return null;
  }
}

void showCarRentalModal(BuildContext context, Business business) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return CarRentalModal(business: business);
    },
  );
}

class CarRentalModal extends StatefulWidget {
  final Business business;

  const CarRentalModal({Key? key, required this.business}) : super(key: key);

  @override
  _CarRentalModalState createState() => _CarRentalModalState();
}

class _CarRentalModalState extends State<CarRentalModal> {
  final PageController _pageController = PageController();
  final CarRentalData _data = CarRentalData();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.page == 0 && _data.selectedVehicleType == null) {
      _showSnackBar('Veuillez sélectionner un type de véhicule');
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
        _data.rentalStartDate != null &&
        _data.rentalEndDate != null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<DateTime?> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      locale: const Locale('fr', 'FR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  Future<void> _saveReservation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicleTypes = widget.business.specificData['vehicleTypes'] as List? ?? [];
      final totalAmount = _data.calculateTotal(vehicleTypes);

      final reservation = Reservation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        establishmentName: widget.business.name,
        reservationType: 'car_rental',
        customerName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        totalAmount: totalAmount,
        reservationDate: DateTime.now(),
        vehicleType: _data.selectedVehicleType,
        rentalStartDate: _data.rentalStartDate,
        rentalEndDate: _data.rentalEndDate,
        rentalDays: _data.rentalDays,
        withDriver: _data.withDriver,
        includeInsurance: _data.includeInsurance,
        needDelivery: _data.needDelivery,
      );

      await ReservationService.saveReservation(reservation);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Réservation confirmée pour ${_data.selectedVehicleType} chez ${widget.business.name}!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la réservation: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 360;
        final bool isMediumScreen = constraints.maxWidth < 400;
        final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;
        final double titleFontSize = isSmallScreen ? 18.0 : 20.0;
        final double bodyFontSize = isSmallScreen ? 14.0 : 16.0;
        final double iconSize = isSmallScreen ? 18.0 : 24.0;
        final double buttonPadding = isSmallScreen ? 12.0 : 16.0;

        return Container(
          height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.85 : 0.9),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground, //
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // HEADER RESPONSIVE
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_pageController.hasClients && _pageController.page! > 0)
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: AppColors.primary,
                            size: isSmallScreen ? 18 : 24),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                      ),
                    if (!(_pageController.hasClients && _pageController.page! > 0))
                      SizedBox(width: isSmallScreen ? 40 : 48),

                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _getPageTitle(_pageController.hasClients ? _pageController.page!.round() : 0),
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            widget.business.name,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: Icon(Icons.close,
                          color: AppColors.primary,
                          size: isSmallScreen ? 18 : 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.grey),

              _buildProgressIndicator(isSmallScreen),
              SizedBox(height: isSmallScreen ? 12 : 16),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSelectVehiclePage(isSmallScreen, isMediumScreen, horizontalPadding),
                    _buildInformationDetailPage(isSmallScreen, horizontalPadding, bodyFontSize),
                    _buildOrderSummaryPage(isSmallScreen, horizontalPadding, bodyFontSize, buttonPadding),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [0, 1, 2].map((index) {
          final currentPage = _pageController.hasClients ? _pageController.page!.round() : 0;
          return Container(
            width: isSmallScreen ? 6 : 8,
            height: isSmallScreen ? 6 : 8,
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentPage >= index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0: return 'Sélection du véhicule';
      case 1: return 'Informations';
      case 2: return 'Récapitulatif';
      default: return '';
    }
  }

  Widget _buildSelectVehiclePage(bool isSmallScreen, bool isMediumScreen, double horizontalPadding) {
    final vehicleTypes = widget.business.specificData['vehicleTypes'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            'Choisissez votre véhicule',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: vehicleTypes.length,
            itemBuilder: (context, index) {
              final vehicleType = vehicleTypes[index];
              final isSelected = _data.selectedVehicleType == vehicleType['type'];
              final dailyPrice = (vehicleType['dailyPrice'] as num?)?.toDouble() ?? 0.0;
              final examples = (vehicleType['examples'] as List?)?.cast<String>() ?? [];
              final features = (vehicleType['features'] as List?)?.cast<String>() ?? [];

              return Card(
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                child: ListTile(
                  leading: Icon(
                    Icons.directions_car,
                    color: isSelected ? AppColors.primary : Colors.grey,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  title: Text(
                    vehicleType['type'] ?? '',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        examples.join(', '),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        '\$$dailyPrice/jour',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (features.isNotEmpty) ...[
                        SizedBox(height: isSmallScreen ? 2 : 4),
                        Text(
                          features.take(2).join(', '),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  trailing: isSelected ? Icon(Icons.check_circle,
                      color: Colors.green,
                      size: isSmallScreen ? 18 : 20) : null,
                  onTap: () => setState(() => _data.selectedVehicleType = vehicleType['type']),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                ),
              );
            },
          ),
        ),

        // BOUTON CONTINUER RESPONSIVE
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _data.selectedVehicleType != null ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _data.selectedVehicleType != null
                    ? AppColors.primary
                    : Colors.grey[300],
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 14 : 16,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Continuer",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: _data.selectedVehicleType != null ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
      ],
    );
  }

  Widget _buildInformationDetailPage(bool isSmallScreen, double horizontalPadding, double bodyFontSize) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
            child: Text(
              'Vos informations de réservation',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _buildTextField("Nom complet", "Votre nom complet", _fullNameController,
              isSmallScreen: isSmallScreen, isRequired: true),

          _buildTextField("Numéro de téléphone", "Entrez votre numéro", _phoneController,
              isSmallScreen: isSmallScreen, keyboardType: TextInputType.phone, isRequired: true),

          // DATES EN COLONNE POUR PETITS ÉCRANS, EN LIGNE POUR GRANDS
          if (isSmallScreen) ...[
            _buildDateOrTimePicker(
              "Date de début",
              "Sélectionnez la date",
              Icons.calendar_today,
              _data.rentalStartDate != null
                  ? "${_data.rentalStartDate!.day}/${_data.rentalStartDate!.month}/${_data.rentalStartDate!.year}"
                  : "",
                  () async {
                final selectedDate = await _showDatePicker();
                setState(() {
                  _data.rentalStartDate = selectedDate;
                });
              },
              isSmallScreen: isSmallScreen,
            ),
            _buildDateOrTimePicker(
              "Date de fin",
              "Sélectionnez la date",
              Icons.calendar_today,
              _data.rentalEndDate != null
                  ? "${_data.rentalEndDate!.day}/${_data.rentalEndDate!.month}/${_data.rentalEndDate!.year}"
                  : "",
                  () async {
                final selectedDate = await _showDatePicker();
                setState(() {
                  _data.rentalEndDate = selectedDate;
                });
              },
              isSmallScreen: isSmallScreen,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildDateOrTimePicker(
                    "Date de début",
                    "Sélectionnez la date",
                    Icons.calendar_today,
                    _data.rentalStartDate != null
                        ? "${_data.rentalStartDate!.day}/${_data.rentalStartDate!.month}/${_data.rentalStartDate!.year}"
                        : "",
                        () async {
                      final selectedDate = await _showDatePicker();
                      setState(() {
                        _data.rentalStartDate = selectedDate;
                      });
                    },
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildDateOrTimePicker(
                    "Date de fin",
                    "Sélectionnez la date",
                    Icons.calendar_today,
                    _data.rentalEndDate != null
                        ? "${_data.rentalEndDate!.day}/${_data.rentalEndDate!.month}/${_data.rentalEndDate!.year}"
                        : "",
                        () async {
                      final selectedDate = await _showDatePicker();
                      setState(() {
                        _data.rentalEndDate = selectedDate;
                      });
                    },
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            ),

          _buildTextField("Notes", "Ex: Besoin d'un siège bébé...", _notesController,
              isSmallScreen: isSmallScreen, maxLines: 3),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // OPTIONS RESPONSIVE
          _buildOptionSwitch('Avec chauffeur', _data.withDriver,
                  (value) => setState(() => _data.withDriver = value),
              isSmallScreen),
          _buildOptionSwitch('Assurance incluse', _data.includeInsurance,
                  (value) => setState(() => _data.includeInsurance = value),
              isSmallScreen),
          _buildOptionSwitch('Livraison du véhicule', _data.needDelivery,
                  (value) => setState(() => _data.needDelivery = value),
              isSmallScreen),

          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateStep2() ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Continuer",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildOptionSwitch(String title, bool value, ValueChanged<bool> onChanged, bool isSmallScreen) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: isSmallScreen,
    );
  }

  Widget _buildOrderSummaryPage(bool isSmallScreen, double horizontalPadding, double bodyFontSize, double buttonPadding) {
    final vehicleTypes = widget.business.specificData['vehicleTypes'] as List? ?? [];
    final totalAmount = _data.calculateTotal(vehicleTypes);

    Map<String, dynamic>? selectedType;
    if (_data.selectedVehicleType != null) {
      for (final type in vehicleTypes) {
        if (type is Map<String, dynamic> && type['type'] == _data.selectedVehicleType) {
          selectedType = type;
          break;
        }
      }
    }

    final dailyPrice = (selectedType?['dailyPrice'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif de votre réservation',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            'Chez ${widget.business.name}',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // RÉSUMÉ RESPONSIVE
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow("Nom", _fullNameController.text.isNotEmpty
                            ? _fullNameController.text
                            : "Non renseigné", isSmallScreen),
                        _buildSummaryRow("Téléphone", _phoneController.text.isNotEmpty
                            ? _phoneController.text
                            : "Non renseigné", isSmallScreen),
                        _buildSummaryRow("Type de véhicule", _data.selectedVehicleType ?? "Non sélectionné", isSmallScreen),
                        _buildSummaryRow("Date de début", _data.rentalStartDate != null
                            ? "${_data.rentalStartDate!.day}/${_data.rentalStartDate!.month}/${_data.rentalStartDate!.year}"
                            : "Non renseignée", isSmallScreen),
                        _buildSummaryRow("Date de fin", _data.rentalEndDate != null
                            ? "${_data.rentalEndDate!.day}/${_data.rentalEndDate!.month}/${_data.rentalEndDate!.year}"
                            : "Non renseignée", isSmallScreen),
                        _buildSummaryRow("Durée", "${_data.rentalDays} jours", isSmallScreen),
                        _buildSummaryRow("Avec chauffeur", _data.withDriver ? "Oui" : "Non", isSmallScreen),
                        _buildSummaryRow("Assurance incluse", _data.includeInsurance ? "Oui" : "Non", isSmallScreen),
                        _buildSummaryRow("Livraison", _data.needDelivery ? "Oui" : "Non", isSmallScreen),
                        if (_notesController.text.isNotEmpty)
                          _buildSummaryRow("Notes", _notesController.text, isSmallScreen),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // PRIX RESPONSIVE
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow("Location (${_data.rentalDays} jours)",
                            "\$${(dailyPrice * _data.rentalDays).toStringAsFixed(2)}", isSmallScreen),
                        if (_data.withDriver)
                          _buildPriceRow("Service chauffeur",
                              "\$${(50.0 * _data.rentalDays).toStringAsFixed(2)}", isSmallScreen),
                        if (_data.needDelivery)
                          _buildPriceRow("Livraison véhicule", "\$25.00", isSmallScreen),
                        if (!_data.includeInsurance)
                          _buildPriceRow("Assurance (optionnelle)",
                              "\$${(15.0 * _data.rentalDays).toStringAsFixed(2)}", isSmallScreen),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        const Divider(),
                        _buildPriceRow("Total", "\$${totalAmount.toStringAsFixed(2)}",
                            isSmallScreen, isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // BOUTONS RESPONSIVE
          if (isSmallScreen)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : Colors.green,
                      padding: EdgeInsets.symmetric(vertical: buttonPadding),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Confirmer la Réservation",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text(
                      "Modifier les informations",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonPadding),
                    ),
                    child: Text(
                      "Modifier",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : Colors.green,
                      padding: EdgeInsets.symmetric(vertical: buttonPadding),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Confirmer",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {bool isSmallScreen = false, TextInputType? keyboardType, int maxLines = 1, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16
            )),
            if (isRequired)
              Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16)),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 10 : 12,
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) {
            setState(() {});
          },
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildDateOrTimePicker(String label, String hint, IconData icon, String value, VoidCallback onTap,
      {bool isSmallScreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16
            )),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16)),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(icon, size: isSmallScreen ? 18 : 20),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 10 : 12,
                ),
              ),
              controller: TextEditingController(text: value),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isSmallScreen, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 3.0 : 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? (isSmallScreen ? 16 : 18) : (isSmallScreen ? 14 : 16),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? (isSmallScreen ? 16 : 18) : (isSmallScreen ? 14 : 16),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).colorScheme.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}