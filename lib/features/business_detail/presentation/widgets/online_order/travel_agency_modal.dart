import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TravelReservationData {
  String? destination;
  DateTime? departureDate;
  int numberOfPassengers = 1;
  String? fullName;
  String? phoneNumber;
  String? notes;

  double calculateTotal() {
    double pricePerTicket = (destination == "Paris") ? 750.0 : 120.0;
    return pricePerTicket * numberOfPassengers;
  }
}

void showTravelReservationModal(BuildContext context, Business business) {
  final bloc = context.read<BusinessDetailBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => BlocProvider.value(
      value: bloc,
      child: TravelReservationModal(business: business),
    ),
  );
}

class TravelReservationModal extends StatefulWidget {
  final Business business;
  const TravelReservationModal({Key? key, required this.business}) : super(key: key);

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

  bool _validateStep2() {
    return _fullNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _data.departureDate != null;
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isSuccess ? Colors.green : Colors.red, behavior: SnackBarBehavior.floating),
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
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) {
      _showSnackBar('Veuillez vous connecter');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final totalAmount = _data.calculateTotal();

      final reservation = Reservation(
        id: '',
        businessId: widget.business.id,
        userId: authState.user.id,
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
          'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
          height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.85 : 0.9),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              _buildHeader(isSmallScreen, titleFontSize),
              const Divider(height: 1, color: Colors.grey),
              _buildProgressIndicator(isSmallScreen),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSelectDestinationPage(isSmallScreen, horizontalPadding),
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

  Widget _buildHeader(bool isSmallScreen, double titleFontSize) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: isSmallScreen ? 18 : 24),
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
            )
          else
            SizedBox(width: isSmallScreen ? 40 : 48),
          Expanded(
            child: Column(
              children: [
                Text(
                  _getPageTitle(_currentPage),
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
    );
  }

  Widget _buildProgressIndicator(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [0, 1, 2].map((index) {
          return Container(
            width: isSmallScreen ? 6 : 8,
            height: isSmallScreen ? 6 : 8,
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage >= index ? Theme.of(context).colorScheme.primary : Colors.grey[300],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0: return 'Choisir le voyage';
      case 1: return 'Informations';
      case 2: return 'Récapitulatif';
      default: return '';
    }
  }

  Widget _buildSelectDestinationPage(bool isSmallScreen, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Destination", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _data.destination,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.white,
            ),
            hint: const Text("Choisir une destination"),
            items: const [
              DropdownMenuItem(value: "Paris", child: Text("Paris")),
              DropdownMenuItem(value: "Kinshasa", child: Text("Kinshasa")),
            ],
            onChanged: (v) => setState(() => _data.destination = v),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _data.destination != null ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _data.destination != null ? AppColors.primary : Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Continuer", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: _data.destination != null ? Colors.white : Colors.grey[600])),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildInformationPage(bool isSmallScreen, double horizontalPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16), child: Text('Vos informations', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold))),
          _buildTextField("Nom complet", "Votre nom complet", _fullNameController, isSmallScreen: isSmallScreen, isRequired: true),
          _buildTextField("Numéro de téléphone", "Entrez votre numéro", _phoneController, isSmallScreen: isSmallScreen, keyboardType: TextInputType.phone, isRequired: true),
          _buildDatePickerTile("Date de départ", _data.departureDate, () async { final selected = await _showDatePicker(); setState(() => _data.departureDate = selected); }, isSmallScreen),
          _buildCounterField("Nombre de passagers", _data.numberOfPassengers, (value) => setState(() => _data.numberOfPassengers = value), min: 1, max: 9, isSmallScreen: isSmallScreen),
          _buildTextField("Notes", "Demandes spécifiques...", _notesController, isSmallScreen: isSmallScreen, maxLines: 3),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateStep2() ? _nextPage : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text("Continuer", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isSmallScreen = false, TextInputType? keyboardType, int maxLines = 1, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)), if (isRequired) Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16))]),
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

  Widget _buildDatePickerTile(String label, DateTime? date, VoidCallback onTap, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)), Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16))]),
        SizedBox(height: isSmallScreen ? 6 : 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Sélectionnez la date",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.calendar_today, size: isSmallScreen ? 18 : 20),
                filled: true,
                fillColor: Colors.grey[50],
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
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: value > min ? () => onChanged(value - 1) : null, color: value > min ? AppColors.primary : Colors.grey),
              Expanded(child: Text('$value', textAlign: TextAlign.center, style: TextStyle(fontSize: isSmallScreen ? 14 : 16))),
              IconButton(icon: const Icon(Icons.add), onPressed: value < max ? () => onChanged(value + 1) : null, color: value < max ? AppColors.primary : Colors.grey),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildSummaryPage(bool isSmallScreen, double horizontalPadding) {
    final totalAmount = _data.calculateTotal();

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif de votre billet', style: TextStyle(fontSize: isSmallScreen ? 18 : 20, fontWeight: FontWeight.bold)),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInfoContainer(isSmallScreen, [
                    _buildSummaryRow("Nom", _fullNameController.text, isSmallScreen),
                    _buildSummaryRow("Téléphone", _phoneController.text, isSmallScreen),
                    _buildSummaryRow("Destination", _data.destination ?? "", isSmallScreen),
                    _buildSummaryRow("Date de départ", _data.departureDate != null ? "${_data.departureDate!.day}/${_data.departureDate!.month}/${_data.departureDate!.year}" : "", isSmallScreen),
                    _buildSummaryRow("Passagers", "${_data.numberOfPassengers}", isSmallScreen),
                    if (_notesController.text.isNotEmpty) _buildSummaryRow("Notes", _notesController.text, isSmallScreen),
                  ]),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildInfoContainer(isSmallScreen, [
                    _buildPriceRow("Total Billet(s)", "\$${totalAmount.toStringAsFixed(2)}", isSmallScreen, isTotal: true),
                  ]),
                ],
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildActionButtons(isSmallScreen),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(bool isSmallScreen, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 12 : 14)),
          Expanded(child: Text(value, style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w500), textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis)),
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

  Widget _buildActionButtons(bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveReservation,
              style: ElevatedButton.styleFrom(backgroundColor: _isLoading ? Colors.grey : Colors.green, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 8), Text("Confirmer le Voyage", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))]),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
              child: Text("Modifier les informations", style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: TextButton(onPressed: _isLoading ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text("Modifier", style: TextStyle(fontSize: 16, color: Colors.grey)))),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveReservation,
              style: ElevatedButton.styleFrom(backgroundColor: _isLoading ? Colors.grey : Colors.green, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 8), Text("Confirmer", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))]),
            ),
          ),
        ],
      );
    }
  }
}