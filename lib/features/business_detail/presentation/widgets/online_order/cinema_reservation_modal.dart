import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/reservation_service.dart';

void showCinemaReservationModal(
    BuildContext context, {
      required Business cinema,
      required Map<String, dynamic> movie,
      Map<String, dynamic>? selectedShowtime,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CinemaReservationModal(
      cinema: cinema,
      movie: movie,
      selectedShowtime: selectedShowtime,
    ),
  );
}

class CinemaReservationModal extends StatefulWidget {
  final Business cinema;
  final Map<String, dynamic> movie;
  final Map<String, dynamic>? selectedShowtime;

  const CinemaReservationModal({
    super.key,
    required this.cinema,
    required this.movie,
    this.selectedShowtime,
  });

  @override
  State<CinemaReservationModal> createState() => _CinemaReservationModalState();
}

class _CinemaReservationModalState extends State<CinemaReservationModal> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Map<String, dynamic>? _selectedShowtime;
  int _numberOfTickets = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedShowtime = widget.selectedShowtime ?? (widget.movie['showtimes'] as List?)?.first;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get totalPrice {
    if (_selectedShowtime == null) return 0.0;
    final price = (_selectedShowtime!['price'] as num?)?.toDouble() ?? 0.0;
    return price * _numberOfTickets;
  }

  void _saveReservation() async {
    if (_fullNameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final reservation = Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      establishmentName: widget.cinema.name,
      reservationType: 'cinema',
      customerName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      totalAmount: totalPrice,
      reservationDate: DateTime.now(),
      movieTitle: widget.movie['title'],
      // On pourrait combiner date+heure, mais pour simplifier on met juste l'heure dans showtime
      showtime: _selectedShowtime != null ? DateTime.now() : null, // À améliorer
      ticketType: _selectedShowtime?['room'],
      numberOfTickets: _numberOfTickets,
    );

    try {
      await ReservationService.saveReservation(reservation);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation confirmée !'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: screenHeight * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Réserver ${widget.movie['title']}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Séance', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (widget.movie['showtimes'] as List?)?.map<Widget>((show) {
              final isSelected = _selectedShowtime == show;
              return ChoiceChip(
                label: Text('${show['time']} (${show['price']}€)'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedShowtime = selected ? show : null);
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.green.withOpacity(0.2),
              );
            }).toList() ??
                [],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nombre de tickets', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _numberOfTickets > 1
                        ? () => setState(() => _numberOfTickets--)
                        : null,
                  ),
                  Text('$_numberOfTickets'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _numberOfTickets++),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Nom complet *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optionnel)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${totalPrice.toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}