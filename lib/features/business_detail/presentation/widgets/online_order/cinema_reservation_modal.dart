import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'reservation_service.dart';

class CinemaReservationData {
  String? selectedMovie;
  DateTime? showtimeDate;
  String? selectedTime;
  String? ticketType;
  int numberOfTickets = 1;
  String? fullName;
  String? phoneNumber;
  String? notes;

  double calculateTotal(Map<String, dynamic> prices) {
    if (ticketType == null) return 0.0;
    double price = 0.0;
    switch (ticketType) {
      case 'standard':
        price = prices['standard'] ?? 0.0;
        break;
      case 'vip':
        price = prices['vip'] ?? 0.0;
        break;
      case 'student':
        price = prices['student'] ?? 0.0;
        break;
      default:
        return 0.0;
    }
    return price * numberOfTickets;
  }
}

void showCinemaReservationModal(BuildContext context, Business business) {
  final canReserve = business.specificData['canReserve'] != false;

  if (!canReserve) {
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
        delegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: CinemaReservationModal(business: business),
      );
    },
  );
}

class CinemaReservationModal extends StatefulWidget {
  final Business business;
  const CinemaReservationModal({Key? key, required this.business}) : super(key: key);

  @override
  State<CinemaReservationModal> createState() => _CinemaReservationModalState();
}

class _CinemaReservationModalState extends State<CinemaReservationModal> {
  final PageController _pageController = PageController();
  final CinemaReservationData _data = CinemaReservationData();

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
    if (_pageController.page == 0 && _data.selectedMovie == null) {
      _showSnackBar('Veuillez sélectionner un film');
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
        _data.showtimeDate != null &&
        _data.selectedTime != null &&
        _data.ticketType != null;
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
      final prices = widget.business.specificData['prices'] as Map<String, dynamic>? ?? {};
      final totalAmount = _data.calculateTotal(prices);

      final showtimeDateTime = DateTime(
        _data.showtimeDate!.year,
        _data.showtimeDate!.month,
        _data.showtimeDate!.day,
        int.parse(_data.selectedTime!.split(':')[0]),
        int.parse(_data.selectedTime!.split(':')[1]),
      );

      final reservation = Reservation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        establishmentName: widget.business.name,
        reservationType: 'cinema',
        customerName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        totalAmount: totalAmount,
        reservationDate: DateTime.now(),
        movieTitle: _data.selectedMovie,
        showtime: showtimeDateTime,
        ticketType: _data.ticketType,
        numberOfTickets: _data.numberOfTickets,
      );

      await ReservationService.saveReservation(reservation);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation confirmée !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
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
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_pageController.hasClients && _pageController.page! > 0)
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: AppColors.primary, size: isSmallScreen ? 18 : 24),
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
              const Divider(height: 1, color: Colors.grey),
              _buildProgressIndicator(isSmallScreen),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSelectMoviePage(isSmallScreen, horizontalPadding),
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
          final currentPage = _pageController.hasClients ? _pageController.page!.round() : 0;
          return Container(
            width: isSmallScreen ? 6 : 8,
            height: isSmallScreen ? 6 : 8,
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentPage >= index ? Theme.of(context).colorScheme.primary : Colors.grey[300],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0: return 'Choisir un film';
      case 1: return 'Informations';
      case 2: return 'Récapitulatif';
      default: return '';
    }
  }

  // Page 1 : Sélection du film
  Widget _buildSelectMoviePage(bool isSmallScreen, double horizontalPadding) {
    final movies = widget.business.specificData['movies'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            'Quel film souhaitez-vous voir ?',
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.grey[600]),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final isSelected = _data.selectedMovie == movie['title'];
              final duration = movie['duration'] ?? 0;
              final rating = movie['rating'] ?? 0;
              final poster = movie['poster'] ?? '';

              return Card(
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      poster,
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.movie, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    movie['title'] ?? '',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Durée: $duration min',
                        style: TextStyle(fontSize: isSmallScreen ? 11 : 13),
                      ),
                      if (rating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(' $rating', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                    ],
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.green, size: isSmallScreen ? 18 : 20)
                      : null,
                  onTap: () => setState(() => _data.selectedMovie = movie['title']),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
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
              onPressed: _data.selectedMovie != null ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _data.selectedMovie != null ? AppColors.primary : Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Continuer",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: _data.selectedMovie != null ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
      ],
    );
  }

  // Page 2 : Informations
  Widget _buildInformationPage(bool isSmallScreen, double horizontalPadding) {
    final showtimes = widget.business.specificData['showtimes'] as List? ?? [];
    final prices = widget.business.specificData['prices'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
            child: Text(
              'Vos informations',
              style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildTextField("Nom complet", "Votre nom complet", _fullNameController,
              isSmallScreen: isSmallScreen, isRequired: true),
          _buildTextField("Numéro de téléphone", "Entrez votre numéro", _phoneController,
              isSmallScreen: isSmallScreen, keyboardType: TextInputType.phone, isRequired: true),

          // Date de la séance
          _buildDatePickerTile(
            "Date de la séance",
            Icons.calendar_today,
            _data.showtimeDate,
                () async {
              final selected = await _showDatePicker();
              setState(() => _data.showtimeDate = selected);
            },
            isSmallScreen,
          ),

          // Heure de la séance
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Heure de la séance",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16),
                  ),
                  Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16)),
                ],
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: showtimes.map<Widget>((time) {
                  final isSelected = _data.selectedTime == time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _data.selectedTime = selected ? time : null);
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  );
                }).toList(),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
            ],
          ),

          // Type de billet
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Type de billet",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16),
                  ),
                  Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16)),
                ],
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (prices.containsKey('standard'))
                    ChoiceChip(
                      label: Text('Standard (\$${prices['standard']})'),
                      selected: _data.ticketType == 'standard',
                      onSelected: (selected) => setState(() => _data.ticketType = selected ? 'standard' : null),
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: _data.ticketType == 'standard' ? Colors.white : Colors.black),
                    ),
                  if (prices.containsKey('vip'))
                    ChoiceChip(
                      label: Text('VIP (\$${prices['vip']})'),
                      selected: _data.ticketType == 'vip',
                      onSelected: (selected) => setState(() => _data.ticketType = selected ? 'vip' : null),
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: _data.ticketType == 'vip' ? Colors.white : Colors.black),
                    ),
                  if (prices.containsKey('student'))
                    ChoiceChip(
                      label: Text('Étudiant (\$${prices['student']})'),
                      selected: _data.ticketType == 'student',
                      onSelected: (selected) => setState(() => _data.ticketType = selected ? 'student' : null),
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: _data.ticketType == 'student' ? Colors.white : Colors.black),
                    ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
            ],
          ),

          // Nombre de places
          _buildCounterField(
            "Nombre de places",
            _data.numberOfTickets,
                (value) => setState(() => _data.numberOfTickets = value),
            min: 1,
            max: 10,
            isSmallScreen: isSmallScreen,
          ),

          _buildTextField("Notes", "Ex: Allergies, préférences...", _notesController,
              isSmallScreen: isSmallScreen, maxLines: 3),

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
              child: Text(
                "Continuer",
                style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  // Page 3 : Récapitulatif
  Widget _buildSummaryPage(bool isSmallScreen, double horizontalPadding) {
    final prices = widget.business.specificData['prices'] as Map<String, dynamic>? ?? {};
    final totalAmount = _data.calculateTotal(prices);
    final movies = widget.business.specificData['movies'] as List? ?? [];
    Map<String, dynamic>? selectedMovie;
    if (_data.selectedMovie != null) {
      for (final movie in movies) {
        if (movie is Map && movie['title'] == _data.selectedMovie) {
          selectedMovie = Map<String, dynamic>.from(movie);
          break;
        }
      }
    }

    double unitPrice = 0.0;
    if (_data.ticketType != null && prices.containsKey(_data.ticketType)) {
      unitPrice = prices[_data.ticketType]?.toDouble() ?? 0.0;
    }

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif de votre réservation',
            style: TextStyle(fontSize: isSmallScreen ? 18 : 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Chez ${widget.business.name}',
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.grey[600]),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
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
                        _buildSummaryRow(
                          "Nom",
                          _fullNameController.text.isNotEmpty ? _fullNameController.text : "Non renseigné",
                          isSmallScreen,
                        ),
                        _buildSummaryRow(
                          "Téléphone",
                          _phoneController.text.isNotEmpty ? _phoneController.text : "Non renseigné",
                          isSmallScreen,
                        ),
                        _buildSummaryRow(
                          "Film",
                          _data.selectedMovie ?? "Non sélectionné",
                          isSmallScreen,
                        ),
                        _buildSummaryRow(
                          "Date",
                          _data.showtimeDate != null
                              ? "${_data.showtimeDate!.day}/${_data.showtimeDate!.month}/${_data.showtimeDate!.year}"
                              : "Non renseignée",
                          isSmallScreen,
                        ),
                        _buildSummaryRow(
                          "Heure",
                          _data.selectedTime ?? "Non renseignée",
                          isSmallScreen,
                        ),
                        _buildSummaryRow(
                          "Type de billet",
                          _data.ticketType == 'standard' ? 'Standard' :
                          _data.ticketType == 'vip' ? 'VIP' :
                          _data.ticketType == 'student' ? 'Étudiant' : 'Non spécifié',
                          isSmallScreen,
                        ),
                        _buildSummaryRow(
                          "Places",
                          "${_data.numberOfTickets}",
                          isSmallScreen,
                        ),
                        if (_notesController.text.isNotEmpty)
                          _buildSummaryRow("Notes", _notesController.text, isSmallScreen),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow(
                          "Prix unitaire",
                          "\$${unitPrice.toStringAsFixed(2)}",
                          isSmallScreen,
                        ),
                        _buildPriceRow(
                          "Nombre de places",
                          "${_data.numberOfTickets}",
                          isSmallScreen,
                        ),
                        const Divider(),
                        _buildPriceRow(
                          "Total",
                          "\$${totalAmount.toStringAsFixed(2)}",
                          isSmallScreen,
                          isTotal: true,
                        ),
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
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
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
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
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

  // Widgets réutilisables
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

  Widget _buildCounterField(String label, int value, void Function(int) onChanged,
      {required int min, required int max, bool isSmallScreen = false}) {
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

  Widget _buildSummaryRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 12 : 14)),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w500),
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
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? (isSmallScreen ? 16 : 18) : (isSmallScreen ? 14 : 16),
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: isTotal ? (isSmallScreen ? 16 : 18) : (isSmallScreen ? 14 : 16),
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Theme.of(context).colorScheme.primary : Colors.black)),
        ],
      ),
    );
  }
}