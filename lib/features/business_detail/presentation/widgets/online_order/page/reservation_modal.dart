import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
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
  final isRestaurant = business.type.name == 'restaurant' || business.type.name == 'restaurent';
  final canReserve = business.specificData['canReserve'] == true;

  if (!isRestaurant || !canReserve) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('La réservation n\'est pas disponible pour ${business.name}'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
  final List<String> _floors = ['Rez-de-chaussée', '1er Étage', '2ème Étage', 'Terrasse'];
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
        backgroundColor: Colors.red,
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

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) {
      _showSnackBar('Veuillez vous connecter');
      setState(() => _isLoading = false);
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

    final userId = authState.user.id;

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
        "notes": _notesController.text.isNotEmpty ? _notesController.text : null,
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
        color: AppColors.scaffoldBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_pageController.hasClients && _pageController.page! > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                if (!(_pageController.hasClients && _pageController.page! > 0))
                  const SizedBox(width: 48),

                Column(
                  children: [
                    Text(
                      _getPageTitle(_pageController.hasClients ? _pageController.page!.round() : 0),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.business.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          _buildProgressIndicator(),
          const SizedBox(height: 16),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSelectTablePage(),
                _buildInformationDetailPage(),
                _buildOrderSummaryPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [0, 1, 2].map((index) {
          final currentPage = _pageController.hasClients ? _pageController.page!.round() : 0;
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentPage >= index ? AppColors.secondary : Colors.grey[300],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0: return 'Sélection de table';
      case 1: return 'Informations';
      case 2: return 'Récapitulatif';
      default: return '';
    }
  }

  Widget _buildSelectTablePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Choisissez votre table préférée',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _floors.map((floor) {
                bool isSelected = _selectedFloor == floor;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(floor),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFloor = floor;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.secondary,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).canvasColor : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final tableNumber = 1 + index;
              final isSelected = _selectedTable == tableNumber.toString();
              final isReserved = [2, 5, 8].contains(tableNumber);

              return GestureDetector(
                onTap: isReserved
                    ? null
                    : () {
                  setState(() {
                    _selectedTable = tableNumber.toString();
                    _data.selectedTable = _selectedTable;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isReserved
                        ? Colors.grey
                        : (isSelected ? AppColors.secondary : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_restaurant,
                              size: 30,
                              color: isReserved
                                  ? Colors.white
                                  : (isSelected ? Colors.white : Colors.black),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Table $tableNumber',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isReserved
                                    ? Colors.white
                                    : (isSelected ? Colors.white : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isReserved)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Réservée',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedTable != null ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTable != null ? AppColors.secondary : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
              child: Text(
                "Réserver une table",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _selectedTable != null ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformationDetailPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Vos informations de réservation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _buildTextField("Nom complet", "Votre nom complet", _fullNameController,
              icon: Icons.person, isRequired: true),

          _buildTextField("Numéro de téléphone", "Entrez votre numéro", _phoneController,
              icon: Icons.phone, keyboardType: TextInputType.phone, isRequired: true),

          Row(
            children: [
              Expanded(
                child: _buildDateOrTimePicker(
                  "Date d'arrivée",
                  "Sélectionnez la date",
                  Icons.calendar_today,
                  _data.date != null
                      ? "${_data.date!.day}/${_data.date!.month}/${_data.date!.year}"
                      : "",
                      () async {
                    final selectedDate = await _showDatePicker();
                    setState(() {
                      _data.date = selectedDate;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDateOrTimePicker(
                  "Heure d'arrivée",
                  "Sélectionnez l'heure",
                  Icons.access_time,
                  _data.time != null ? _data.time!.format(context) : "",
                      () async {
                    final selectedTime = await _showTimePicker();
                    setState(() {
                      _data.time = selectedTime;
                    });
                  },
                ),
              ),
            ],
          ),

          _buildTextField("Nombre de personnes", "Combien de personnes", _peopleController,
              icon: Icons.people, keyboardType: TextInputType.number, isRequired: true),

          _buildTextField("Notes", "Ex: Besoin de 2 chaises bébé...", _notesController,
              icon: Icons.note, maxLines: 3),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateStep2() ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
              child: const Text(
                "Continuer",
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {IconData? icon, TextInputType? keyboardType, int maxLines = 1, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (isRequired) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: Colors.grey[50],
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateOrTimePicker(String label, String hint, IconData icon, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(icon, size: 20),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              controller: TextEditingController(text: value),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOrderSummaryPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif de votre réservation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Chez ${widget.business.name}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: [
                _buildSummaryRow("Nom", _fullNameController.text.isNotEmpty
                    ? _fullNameController.text
                    : "Non renseigné"),
                _buildSummaryRow("Téléphone", _phoneController.text.isNotEmpty
                    ? _phoneController.text
                    : "Non renseigné"),
                _buildSummaryRow("Date", _data.date != null
                    ? "${_data.date!.day}/${_data.date!.month}/${_data.date!.year}"
                    : "Non renseignée"),
                _buildSummaryRow("Heure", _data.time != null
                    ? _data.time!.format(context)
                    : "Non renseignée"),
                _buildSummaryRow("Nombre de personnes", _peopleController.text.isNotEmpty
                    ? _peopleController.text
                    : "Non renseigné"),
                _buildSummaryRow("Table", _data.selectedTable?.toString() ?? "Non sélectionnée"),
                _buildSummaryRow("Étage", _selectedFloor),
                if (_notesController.text.isNotEmpty) _buildSummaryRow("Notes", _notesController.text),
              ],
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: [
                _buildPriceRow("Sous-total", "\$${_data.subtotal.toStringAsFixed(2)}"),
                _buildPriceRow("Taxe", "\$${_data.tax.toStringAsFixed(2)}"),
                const SizedBox(height: 10),
                const Divider(),
                _buildPriceRow("Total", "\$${_data.grandTotal.toStringAsFixed(2)}", isTotal: true),
              ],
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? Colors.grey : AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Payer et Réserver",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: const Text(
                "Modifier les informations",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.secondary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}