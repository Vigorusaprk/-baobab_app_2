import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TourismReservationData {
  List<String> selectedActivities = [];
  DateTime? activityDate;
  int numberOfParticipants = 1;
  String? fullName;
  String? phoneNumber;
  String? notes;

  double calculateTotal(List<dynamic> activities) {
    double total = 0.0;
    for (final name in selectedActivities) {
      for (final a in activities) {
        if (a is Map && a['name'] == name) {
          total += (a['price'] as num?)?.toDouble() ?? 0.0;
          break;
        }
      }
    }
    return total * numberOfParticipants;
  }

  List<Map<String, dynamic>> getSelectedActivitiesWithPrices(List<dynamic> allActivities) {
    List<Map<String, dynamic>> result = [];
    for (final name in selectedActivities) {
      for (final a in allActivities) {
        if (a is Map && a['name'] == name) {
          result.add({
            'name': name,
            'price': a['price'],
            'duration': a['duration'],
            'location': a['location'],
          });
          break;
        }
      }
    }
    return result;
  }
}

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
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) {
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
        userId: authState.user.id,
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

        return Container(
          height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.85 : 0.9),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
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
              ),
              const Divider(height: 1, color: Colors.grey),
              _buildProgressIndicator(isSmallScreen),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSelectActivitiesPage(isSmallScreen, horizontalPadding),
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
      case 0: return 'Choisir vos activités';
      case 1: return 'Informations';
      case 2: return 'Récapitulatif';
      default: return '';
    }
  }

  Widget _buildSelectActivitiesPage(bool isSmallScreen, double horizontalPadding) {
    final activities = widget.business.specificData['activities'] as List? ?? [];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final name = activity['name'] ?? '';
              final price = (activity['price'] as num?)?.toDouble() ?? 0.0;
              final duration = activity['duration'] ?? 0;
              final description = activity['description'] ?? '';
              final location = activity['location'] ?? '';
              final isSelected = _data.selectedActivities.contains(name);

              return Container(
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(width: 2, color: AppColors.primary) : Border.all(width: 2.5, color: Colors.transparent),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) _data.selectedActivities.remove(name);
                      else _data.selectedActivities.add(name);
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) _data.selectedActivities.add(name);
                              else _data.selectedActivities.remove(name);
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(location, style: TextStyle(fontSize: isSmallScreen ? 11 : 13))]),
                              Text('Durée: $duration min', style: TextStyle(fontSize: isSmallScreen ? 11 : 13)),
                              Text('\$$price / personne', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
              Text('${_data.selectedActivities.length} activité(s) sélectionnée(s)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
              Text('Total: \$${_data.calculateTotal(activities).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: isSmallScreen ? 14 : 16)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _data.selectedActivities.isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _data.selectedActivities.isNotEmpty ? AppColors.primary : Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Continuer", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: _data.selectedActivities.isNotEmpty ? Colors.white : Colors.grey[600])),
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
          Padding(padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16), child: Text('Vos informations', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold))),
          _buildTextField("Nom complet", "Votre nom complet", _fullNameController, isSmallScreen: isSmallScreen, isRequired: true),
          _buildTextField("Numéro de téléphone", "Entrez votre numéro", _phoneController, isSmallScreen: isSmallScreen, keyboardType: TextInputType.phone, isRequired: true),
          _buildDatePickerTile("Date de l'activité", Icons.calendar_today, _data.activityDate, () async {
            final selected = await _showDatePicker();
            setState(() => _data.activityDate = selected);
          }, isSmallScreen),
          _buildCounterField("Nombre de participants", _data.numberOfParticipants, (value) => setState(() => _data.numberOfParticipants = value), min: 1, max: 20, isSmallScreen: isSmallScreen),
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

  Widget _buildDatePickerTile(String label, IconData icon, DateTime? date, VoidCallback onTap, bool isSmallScreen) {
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
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: value > min ? () => onChanged(value - 1) : null, color: value > min ? AppColors.primary : Colors.grey, iconSize: isSmallScreen ? 16 : 20),
              Expanded(child: Text('$value', textAlign: TextAlign.center, style: TextStyle(fontSize: isSmallScreen ? 14 : 16))),
              IconButton(icon: const Icon(Icons.add), onPressed: value < max ? () => onChanged(value + 1) : null, color: value < max ? AppColors.primary : Colors.grey, iconSize: isSmallScreen ? 16 : 20),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildSummaryPage(bool isSmallScreen, double horizontalPadding) {
    final activities = widget.business.specificData['activities'] as List? ?? [];
    final totalAmount = _data.calculateTotal(activities);
    final selectedActivitiesWithPrices = _data.getSelectedActivitiesWithPrices(activities);

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
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                    child: Column(
                      children: [
                        _buildSummaryRow("Nom", _fullNameController.text.isNotEmpty ? _fullNameController.text : "Non renseigné", isSmallScreen),
                        _buildSummaryRow("Téléphone", _phoneController.text.isNotEmpty ? _phoneController.text : "Non renseigné", isSmallScreen),
                        _buildSummaryRow("Date", _data.activityDate != null ? "${_data.activityDate!.day}/${_data.activityDate!.month}/${_data.activityDate!.year}" : "Non renseignée", isSmallScreen),
                        _buildSummaryRow("Participants", "${_data.numberOfParticipants}", isSmallScreen),
                        if (_notesController.text.isNotEmpty) _buildSummaryRow("Notes", _notesController.text, isSmallScreen),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Activités sélectionnées', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        ...selectedActivitiesWithPrices.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 14))), Text('\$${item['price']}', style: const TextStyle(fontWeight: FontWeight.w500))]),
                              if (item['location'] != null) Row(children: [Icon(Icons.location_on, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(item['location'], style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                            ],
                          ),
                        )),
                        const Divider(height: 20),
                        _buildPriceRow("Total (${_data.numberOfParticipants} part.)", "\$${totalAmount.toStringAsFixed(2)}", isSmallScreen, isTotal: true),
                      ],
                    ),
                  ),
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
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 8), Text("Confirmer la Réservation", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))]),
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
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 8), Text("Confirmer", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))]),
            ),
          ),
        ],
      );
    }
  }
}