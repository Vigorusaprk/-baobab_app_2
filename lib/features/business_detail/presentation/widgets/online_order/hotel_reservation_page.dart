import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/room.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/room_api_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // ✅ pour context.go

class HotelReservationPage extends StatefulWidget {
  final Business hotel;

  const HotelReservationPage({super.key, required this.hotel});

  @override
  State<HotelReservationPage> createState() => _HotelReservationPageState();
}

class _HotelReservationPageState extends State<HotelReservationPage> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _rooms = 1;        // ✅ au lieu de _roomsCount
  int _adults = 2;
  int _children = 0;
  List<Room> _roomsList = [];
  bool _isLoading = true;
  Room? _selectedRoom;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final RoomApiService _roomApiService = RoomApiService();

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await _roomApiService.getRoomsByHotel(widget.hotel.id);
      setState(() => _roomsList = rooms);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement chambres: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _book() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      context.go('/login'); // ✅ redirection vers login
      return;
    }
    final userId = authState.user.id;

    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une chambre'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir les dates'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir votre nom et téléphone'), backgroundColor: Colors.orange),
      );
      return;
    }

    final nights = _checkOut!.difference(_checkIn!).inDays;
    final totalAmount = _selectedRoom!.pricePerNight * nights * _rooms;

    final reservation = ReservationModel(
      businessId: widget.hotel.id,
      userId: userId,
      type: "hotel",
      reservationDate: DateTime.now(),
      totalAmount: totalAmount,
      details: {
        "room_id": _selectedRoom!.id,
        "room_type": _selectedRoom!.roomType,
        "check_in": _checkIn!.toIso8601String(),
        "check_out": _checkOut!.toIso8601String(),
        "nights": nights,
        "rooms": _rooms,
        "adults": _adults,
        "children": _children,
        "customer_name": _nameController.text,
        "phone": _phoneController.text,
        "notes": _notesController.text,
      },
    );

    try {
      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation confirmée !'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- UI (inchangé) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réserver chez ${widget.hotel.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSection(),
            const SizedBox(height: 24),
            _buildGuestsSection(),
            const SizedBox(height: 24),
            const Text('Chambres disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._roomsList.map((room) => _buildRoomCard(room)),
            const SizedBox(height: 24),
            const Text('Vos coordonnées', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom complet', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optionnel)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _book,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirmer la réservation', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dates du séjour', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _datePickerTile(
                    label: 'Arrivée',
                    date: _checkIn,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _checkIn = picked);
                        // Si la date de départ est antérieure, la réinitialiser
                        if (_checkOut != null && _checkOut!.isBefore(picked)) {
                          setState(() => _checkOut = null);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _datePickerTile(
                    label: 'Départ',
                    date: _checkOut,
                    onTap: () async {
                      if (_checkIn == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Choisissez d\'abord une date d\'arrivée'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _checkIn!.add(const Duration(days: 1)),
                        firstDate: _checkIn!.add(const Duration(days: 1)),
                        lastDate: _checkIn!.add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _checkOut = picked);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerTile({required String label, required DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormat('dd/MM/yyyy').format(date) : label,
                style: TextStyle(color: date != null ? Colors.black : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _counterRow('Chambres', _rooms, (v) => setState(() => _rooms = v), 1, 5),
            const Divider(),
            _counterRow('Adultes', _adults, (v) => setState(() => _adults = v), 1, 10),
            const Divider(),
            _counterRow('Enfants', _children, (v) => setState(() => _children = v), 0, 5),
          ],
        ),
      ),
    );
  }

  Widget _counterRow(String label, int value, ValueChanged<int> onChanged, int min, int max) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomCard(Room room) {
    final bool isSelected = _selectedRoom == room;
    final nights = _checkIn != null && _checkOut != null
        ? _checkOut!.difference(_checkIn!).inDays
        : 0;
    final total = room.pricePerNight * nights * _rooms;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
      child: InkWell(
        onTap: () => setState(() => _selectedRoom = room),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      room.roomType,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 4),
              Text('Capacité: ${room.capacity} personnes', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text('Prix: ${room.pricePerNight.toStringAsFixed(2)} € / nuit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              if (nights > 0)
                Text('Total pour $nights nuits et $_rooms chambre(s): ${total.toStringAsFixed(2)} €',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              if (room.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(room.description!, style: TextStyle(color: Colors.grey[700])),
                ),
            ],
          ),
        ),
      ),
    );
  }
}