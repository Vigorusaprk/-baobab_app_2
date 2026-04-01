import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';

class HotelReservationData {
  String? selectedRoomType;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int numberOfRooms = 1;
  int numberOfGuests = 2;
  String? fullName;
  String? phoneNumber;
  String? notes;

  int get nights {
    if (checkInDate != null && checkOutDate != null) {
      final nights = checkOutDate!.difference(checkInDate!).inDays;
      return nights < 1 ? 1 : nights;
    }
    return 0;
  }

  double calculateTotal(List<dynamic> roomTypes) {
    if (selectedRoomType == null) return 0.0;
    final selected = _findRoomType(roomTypes, selectedRoomType!);
    if (selected == null) return 0.0;
    final pricePerNight = (selected['price'] as num?)?.toDouble() ?? 0.0;
    return pricePerNight * nights * numberOfRooms;
  }

  Map<String, dynamic>? _findRoomType(List<dynamic> roomTypes, String typeName) {
    for (final type in roomTypes) {
      if (type is Map<String, dynamic> && type['name'] == typeName) {
        return type;
      }
    }
    return null;
  }
}

class HotelReservationSheet extends StatefulWidget {
  final Business business;
  const HotelReservationSheet({super.key, required this.business});

  @override
  State<HotelReservationSheet> createState() => _HotelReservationSheetState();
}

class _HotelReservationSheetState extends State<HotelReservationSheet> {
  final PageController _pageController = PageController();
  final HotelReservationData _data = HotelReservationData();

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
    if (_pageController.page == 0 && _data.selectedRoomType == null) {
      _showSnackBar('Veuillez sélectionner un type de chambre');
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
        _data.checkInDate != null &&
        _data.checkOutDate != null;
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

  Future<DateTime?> _showDatePicker({required DateTime initialDate, required DateTime firstDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(DateTime.now().year + 2),
      locale: const Locale('fr', 'FR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  Future<void> _saveReservation() async {
    setState(() => _isLoading = true);
    try {
      final roomTypes = widget.business.specificData['roomTypes'] as List? ?? [];
      final totalAmount = _data.calculateTotal(roomTypes);

      final reservation = ReservationModel(
        businessId: widget.business.id,
        userId: "USER_ID_AUTH",
        type: "hotel",
        reservationDate: DateTime.now(),
        totalAmount: totalAmount,
        details: {
          "room_type": _data.selectedRoomType,
          "check_in_date": _data.checkInDate?.toIso8601String(),
          "check_out_date": _data.checkOutDate?.toIso8601String(),
          "number_of_rooms": _data.numberOfRooms,
          "number_of_guests": _data.numberOfGuests,
          "customer_name": _fullNameController.text,
          "phone_number": _phoneController.text,
          "notes": _notesController.text,
        },
      );

      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Réservation confirmée pour une ${_data.selectedRoomType} chez ${widget.business.name}!'),
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
      setState(() => _isLoading = false);
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
          height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.85 : 0.9),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_pageController.hasClients && _pageController.page! > 0)
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: isSmallScreen ? 18 : 24),
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        ),
                      )
                    else
                      SizedBox(width: isSmallScreen ? 40 : 48),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _getPageTitle(_pageController.hasClients ? _pageController.page!.round() : 0),
                            style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            widget.business.name,
                            style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.primary, size: isSmallScreen ? 18 : 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSelectRoomPage(isSmallScreen, horizontalPadding),
                    _buildInformationPage(isSmallScreen, horizontalPadding),
                    _buildSummaryPage(isSmallScreen, horizontalPadding),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- UI methods (inchangées) ---
  String _getPageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0: return 'Sélection de la chambre';
      case 1: return 'Informations';
      case 2: return 'Récapitulatif';
      default: return '';
    }
  }

  Widget _buildSelectRoomPage(bool isSmallScreen, double horizontalPadding) {
    final roomTypes = widget.business.specificData['roomTypes'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            'Choisissez votre type de chambre',
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.grey[600]),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: roomTypes.length,
            itemBuilder: (context, index) {
              final room = roomTypes[index];
              final isSelected = _data.selectedRoomType == room['name'];
              final pricePerNight = (room['price'] as num?)?.toDouble() ?? 0.0;
              final capacity = room['capacity'] ?? 2;

              return Card(
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                child: ListTile(
                  leading: Icon(Icons.bed, color: isSelected ? AppColors.primary : Colors.grey, size: isSmallScreen ? 20 : 24),
                  title: Text(room['name'] ?? '', style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w500)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Capacité: $capacity personnes', style: TextStyle(fontSize: isSmallScreen ? 11 : 13)),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text('\$${pricePerNight.toStringAsFixed(2)} / nuit',
                          style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  trailing: isSelected ? Icon(Icons.check_circle, color: Colors.green, size: isSmallScreen ? 18 : 20) : null,
                  onTap: () => setState(() => _data.selectedRoomType = room['name']),
                  contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 8 : 12),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _data.selectedRoomType != null ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _data.selectedRoomType != null ? AppColors.primary : Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Continuer",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: _data.selectedRoomType != null ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
      ],
    );
  }

  Widget _buildInformationPage(bool isSmallScreen, double horizontalPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
            child: Text('Vos informations de séjour',
                style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold)),
          ),
          _buildTextField("Nom complet", "Votre nom complet", _fullNameController,
              isSmallScreen: isSmallScreen, isRequired: true),
          _buildTextField("Numéro de téléphone", "Entrez votre numéro", _phoneController,
              isSmallScreen: isSmallScreen, keyboardType: TextInputType.phone, isRequired: true),
          if (isSmallScreen) ...[
            _buildDatePickerTile("Date d'arrivée", Icons.calendar_today, _data.checkInDate,
                    () async {
                  final selected = await _showDatePicker(initialDate: DateTime.now(), firstDate: DateTime.now());
                  setState(() => _data.checkInDate = selected);
                }, isSmallScreen),
            _buildDatePickerTile("Date de départ", Icons.calendar_today, _data.checkOutDate,
                    () async {
                  final initialDate = _data.checkInDate ?? DateTime.now().add(const Duration(days: 1));
                  final firstDate = _data.checkInDate ?? DateTime.now();
                  final selected = await _showDatePicker(initialDate: initialDate, firstDate: firstDate);
                  setState(() => _data.checkOutDate = selected);
                }, isSmallScreen),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerTile("Date d'arrivée", Icons.calendar_today, _data.checkInDate,
                          () async {
                        final selected = await _showDatePicker(initialDate: DateTime.now(), firstDate: DateTime.now());
                        setState(() => _data.checkInDate = selected);
                      }, isSmallScreen),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDatePickerTile("Date de départ", Icons.calendar_today, _data.checkOutDate,
                          () async {
                        final initialDate = _data.checkInDate ?? DateTime.now().add(const Duration(days: 1));
                        final firstDate = _data.checkInDate ?? DateTime.now();
                        final selected = await _showDatePicker(initialDate: initialDate, firstDate: firstDate);
                        setState(() => _data.checkOutDate = selected);
                      }, isSmallScreen),
                ),
              ],
            ),
          ],
          Row(
            children: [
              Expanded(child: _buildCounterField("Chambres", _data.numberOfRooms, (v) => setState(() => _data.numberOfRooms = v), min: 1, max: 5, isSmallScreen: isSmallScreen)),
              const SizedBox(width: 10),
              Expanded(child: _buildCounterField("Personnes", _data.numberOfGuests, (v) => setState(() => _data.numberOfGuests = v), min: 1, max: 10, isSmallScreen: isSmallScreen)),
            ],
          ),
          _buildTextField("Notes", "Ex: Demande spéciale...", _notesController, isSmallScreen: isSmallScreen, maxLines: 3),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateStep2() ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Continuer", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
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
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
            if (isRequired) Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16)),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 10 : 12),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildDatePickerTile(String label, IconData icon, DateTime? date, VoidCallback onTap, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16)),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Sélectionnez la date",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(icon, size: isSmallScreen ? 18 : 20),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 10 : 12),
              ),
              controller: TextEditingController(text: date != null ? "${date.day}/${date.month}/${date.year}" : ""),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildCounterField(String label, int value, void Function(int) onChanged, {required int min, required int max, bool isSmallScreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                color: value > min ? AppColors.primary : Colors.grey,
                iconSize: isSmallScreen ? 16 : 20,
              ),
              Expanded(
                child: Text('$value', textAlign: TextAlign.center, style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: value < max ? () => onChanged(value + 1) : null,
                color: value < max ? AppColors.primary : Colors.grey,
                iconSize: isSmallScreen ? 16 : 20,
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildSummaryPage(bool isSmallScreen, double horizontalPadding) {
    final roomTypes = widget.business.specificData['roomTypes'] as List? ?? [];
    final totalAmount = _data.calculateTotal(roomTypes);
    Map<String, dynamic>? selectedRoom;
    if (_data.selectedRoomType != null) {
      for (final room in roomTypes) {
        if (room is Map<String, dynamic> && room['name'] == _data.selectedRoomType) {
          selectedRoom = room;
          break;
        }
      }
    }
    final pricePerNight = (selectedRoom?['price'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif de votre séjour', style: TextStyle(fontSize: isSmallScreen ? 18 : 20, fontWeight: FontWeight.bold)),
          Text('Chez ${widget.business.name}', style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.grey[600])),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                    child: Column(
                      children: [
                        _buildSummaryRow("Nom", _fullNameController.text.isNotEmpty ? _fullNameController.text : "Non renseigné", isSmallScreen),
                        _buildSummaryRow("Téléphone", _phoneController.text.isNotEmpty ? _phoneController.text : "Non renseigné", isSmallScreen),
                        _buildSummaryRow("Type de chambre", _data.selectedRoomType ?? "Non sélectionné", isSmallScreen),
                        _buildSummaryRow("Arrivée", _data.checkInDate != null ? "${_data.checkInDate!.day}/${_data.checkInDate!.month}/${_data.checkInDate!.year}" : "Non renseignée", isSmallScreen),
                        _buildSummaryRow("Départ", _data.checkOutDate != null ? "${_data.checkOutDate!.day}/${_data.checkOutDate!.month}/${_data.checkOutDate!.year}" : "Non renseignée", isSmallScreen),
                        _buildSummaryRow("Nuits", "${_data.nights}", isSmallScreen),
                        _buildSummaryRow("Chambres", "${_data.numberOfRooms}", isSmallScreen),
                        _buildSummaryRow("Personnes", "${_data.numberOfGuests}", isSmallScreen),
                        if (_notesController.text.isNotEmpty) _buildSummaryRow("Notes", _notesController.text, isSmallScreen),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                    child: Column(
                      children: [
                        _buildPriceRow("Prix par nuit", "\$${pricePerNight.toStringAsFixed(2)}", isSmallScreen),
                        _buildPriceRow("Nombre de nuits", "${_data.nights}", isSmallScreen),
                        _buildPriceRow("Nombre de chambres", "${_data.numberOfRooms}", isSmallScreen),
                        const Divider(),
                        _buildPriceRow("Total", "\$${totalAmount.toStringAsFixed(2)}", isSmallScreen, isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          if (isSmallScreen)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : Colors.green,
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text("Confirmer la Réservation", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isLoading ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                    child: Text("Modifier les informations", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                    style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16)),
                    child: Text("Modifier", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : Colors.green,
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text("Confirmer", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildSummaryRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 12 : 14)),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis),
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
          Text(label, style: TextStyle(fontSize: isTotal ? (isSmallScreen ? 16 : 18) : (isSmallScreen ? 14 : 16), fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? (isSmallScreen ? 16 : 18) : (isSmallScreen ? 14 : 16), fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Theme.of(context).colorScheme.primary : Colors.black)),
        ],
      ),
    );
  }
// ... les méthodes _buildTextField, _buildDatePickerTile, _buildCounterRow, _buildSummaryRow, _buildPriceRow restent identiques.
}