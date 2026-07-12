import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpaReservationData {
  List<String> selectedTreatments = [];
  DateTime? appointmentDate;
  TimeOfDay? appointmentTime;
  String? selectedTherapist;
  String? fullName;
  String? phoneNumber;
  String? notes;

  double calculateTotal(List<dynamic> treatments) {
    double total = 0.0;
    for (final name in selectedTreatments) {
      Map<String, dynamic>? treatment;
      for (final t in treatments) {
        if (t is Map && t['name'] == name) {
          treatment = Map<String, dynamic>.from(t);
          break;
        }
      }
      if (treatment != null) {
        total += (treatment['price'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return total;
  }

  List<Map<String, dynamic>> getSelectedTreatmentsWithPrices(List<dynamic> allTreatments) {
    List<Map<String, dynamic>> result = [];
    for (final name in selectedTreatments) {
      Map<String, dynamic>? treatment;
      for (final t in allTreatments) {
        if (t is Map && t['name'] == name) {
          treatment = Map<String, dynamic>.from(t);
          break;
        }
      }
      if (treatment != null) {
        result.add({
          'name': name,
          'price': treatment['price'],
          'duration': treatment['duration'],
        });
      }
    }
    return result;
  }
}

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
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) {
      _showSnackBar('Veuillez vous connecter');
      return;
    }
    final userId = authState.user.id;

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

  List<dynamic> _getTreatmentsList() {
    final data = widget.business.specificData['treatments'];
    if (data is List) return data;
    if (data is Map) return [data];
    return [];
  }

  List<String> _getTherapistNames() {
    final therapists = widget.business.specificData['therapists'];
    if (therapists is List) {
      return therapists.map((t) {
        if (t is Map) return t['name']?.toString() ?? '';
        return t.toString();
      }).where((name) => name.isNotEmpty).toList();
    }
    return [];
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
                    _buildSelectTreatmentPage(isSmallScreen, horizontalPadding),
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
      case 0: return 'Choisir vos soins';
      case 1: return 'Informations';
      case 2: return 'Récapitulatif';
      default: return '';
    }
  }

  Widget _buildSelectTreatmentPage(bool isSmallScreen, double horizontalPadding) {
    final treatments = _getTreatmentsList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: treatments.length,
            itemBuilder: (context, index) {
              final treatment = treatments[index];
              final name = treatment is Map ? (treatment['name']?.toString() ?? '') : treatment.toString();
              final price = treatment is Map ? (treatment['price'] as num?)?.toDouble() ?? 0.0 : 0.0;
              final duration = treatment is Map ? (treatment['duration'] as int?) ?? 0 : 0;
              final description = treatment is Map ? (treatment['description']?.toString() ?? '') : '';
              final isSelected = _data.selectedTreatments.contains(name);

              return Container(
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(width: 2, color: AppColors.primary) : Border.all(width: 2.5, color: Colors.transparent),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: InkWell(
                  onTap: () => _toggleTreatment(name),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleTreatment(name),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              if (duration > 0) Text('Durée: $duration min', style: TextStyle(fontSize: isSmallScreen ? 11 : 13)),
                              if (price > 0) Text('\$$price', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(description, style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_data.selectedTreatments.length} soin(s) sélectionné(s)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
              Text('Total: \$${_data.calculateTotal(treatments).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: isSmallScreen ? 14 : 16)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _data.selectedTreatments.isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _data.selectedTreatments.isNotEmpty ? AppColors.primary : Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Continuer", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: _data.selectedTreatments.isNotEmpty ? Colors.white : Colors.grey[600])),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
      ],
    );
  }

  void _toggleTreatment(String name) {
    setState(() {
      if (_data.selectedTreatments.contains(name)) {
        _data.selectedTreatments.remove(name);
      } else {
        _data.selectedTreatments.add(name);
      }
    });
  }

  Widget _buildInformationPage(bool isSmallScreen, double horizontalPadding) {
    final therapistNames = _getTherapistNames();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16), child: Text('Vos informations', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold))),
          _buildTextField("Nom complet", "Votre nom complet", _fullNameController, isSmallScreen: isSmallScreen, isRequired: true),
          _buildTextField("Numéro de téléphone", "Entrez votre numéro", _phoneController, isSmallScreen: isSmallScreen, keyboardType: TextInputType.phone, isRequired: true),
          if (isSmallScreen) ...[
            _buildDatePickerTile("Date du rendez-vous", _data.appointmentDate, () async { final selected = await _showDatePicker(); setState(() => _data.appointmentDate = selected); }, isSmallScreen),
            _buildTimePickerTile("Heure du rendez-vous", _data.appointmentTime, () async { final selected = await _showTimePicker(); setState(() => _data.appointmentTime = selected); }, isSmallScreen),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildDatePickerTile("Date", _data.appointmentDate, () async { final selected = await _showDatePicker(); setState(() => _data.appointmentDate = selected); }, isSmallScreen)),
                const SizedBox(width: 10),
                Expanded(child: _buildTimePickerTile("Heure", _data.appointmentTime, () async { final selected = await _showTimePicker(); setState(() => _data.appointmentTime = selected); }, isSmallScreen)),
              ],
            ),
          ],
          if (therapistNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Thérapeute (optionnel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: therapistNames.map((name) {
                final isSelected = _data.selectedTherapist == name;
                return ChoiceChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (selected) { setState(() { _data.selectedTherapist = selected ? name : null; }); },
                  backgroundColor: Colors.grey[100],
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.black),
                );
              }).toList(),
            ),
          ],
          _buildTextField("Notes", "Ex: Allergies, préférences...", _notesController, isSmallScreen: isSmallScreen, maxLines: 3),
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
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2.5), borderRadius: BorderRadius.circular(10)),
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

  Widget _buildTimePickerTile(String label, TimeOfDay? time, VoidCallback onTap, bool isSmallScreen) {
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
                hintText: "Sélectionnez l'heure",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.access_time, size: isSmallScreen ? 18 : 20),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 10 : 12),
              ),
              controller: TextEditingController(text: time != null ? time.format(context) : ""),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildSummaryPage(bool isSmallScreen, double horizontalPadding) {
    final treatments = _getTreatmentsList();
    final totalAmount = _data.calculateTotal(treatments);
    final selectedTreatmentsWithPrices = _data.getSelectedTreatmentsWithPrices(treatments);

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif de votre réservation', style: TextStyle(fontSize: isSmallScreen ? 18 : 20, fontWeight: FontWeight.bold)),
          Text('Chez ${widget.business.name}', style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.grey[600])),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInfoContainer(isSmallScreen, [
                    _buildSummaryRow("Nom", _fullNameController.text.isNotEmpty ? _fullNameController.text : "Non renseigné", isSmallScreen),
                    _buildSummaryRow("Téléphone", _phoneController.text.isNotEmpty ? _phoneController.text : "Non renseigné", isSmallScreen),
                    _buildSummaryRow("Date", _data.appointmentDate != null ? "${_data.appointmentDate!.day}/${_data.appointmentDate!.month}/${_data.appointmentDate!.year}" : "Non renseignée", isSmallScreen),
                    _buildSummaryRow("Heure", _data.appointmentTime != null ? _data.appointmentTime!.format(context) : "Non renseignée", isSmallScreen),
                    if (_data.selectedTherapist != null) _buildSummaryRow("Thérapeute", _data.selectedTherapist!, isSmallScreen),
                    if (_notesController.text.isNotEmpty) _buildSummaryRow("Notes", _notesController.text, isSmallScreen),
                  ]),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildInfoContainer(isSmallScreen, [
                    const Text('Soins sélectionnés', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ...selectedTreatmentsWithPrices.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 14))), Text('\$${item['price']}', style: const TextStyle(fontWeight: FontWeight.w500))]),
                    )).toList(),
                    const Divider(height: 20),
                    _buildPriceRow("Total", "\$${totalAmount.toStringAsFixed(2)}", isSmallScreen, isTotal: true),
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
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
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
          Expanded(
            child: Text(value, style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w500), textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis),
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

  Widget _buildActionButtons(bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveReservation,
              style: ElevatedButton.styleFrom(backgroundColor: _isLoading ? Colors.grey : Colors.green, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 8), Text("Confirmer la Réservation", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))]),
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
          Expanded(
            child: TextButton(
              onPressed: _isLoading ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text("Modifier", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          ),
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