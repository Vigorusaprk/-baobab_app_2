import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/room.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/room_api_service.dart';
import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HotelReservationPage extends StatefulWidget {
  final Business hotel;
  const HotelReservationPage({super.key, required this.hotel});

  @override
  State<HotelReservationPage> createState() => _HotelReservationPageState();
}

class _HotelReservationPageState extends State<HotelReservationPage> {
  List<Room> _rooms = [];
  bool _isLoadingRooms = true;
  Room? _selectedRoom;
  DateTime? _checkIn, _checkOut;
  int _roomsCount = 1;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final service = RoomApiService();
    try {
      final rooms = await service.getRoomsByHotel(widget.hotel.id);
      setState(() { _rooms = rooms; _isLoadingRooms = false; });
    } catch (e) {
      setState(() => _isLoadingRooms = false);
    }
  }

  Future<void> _book() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      context.go('/login');
      return;
    }
    if (_selectedRoom == null || _checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisissez une chambre et des dates')));
      return;
    }
    final nights = _checkOut!.difference(_checkIn!).inDays;
    final total = _selectedRoom!.pricePerNight * nights * _roomsCount;
    final reservation = ReservationModel(
      businessId: widget.hotel.id,
      userId: authState.user.id,
      type: 'hotel',
      reservationDate: DateTime.now(),
      totalAmount: total,
      details: {
        'room_id': _selectedRoom!.id,
        'room_type': _selectedRoom!.roomType,
        'check_in_date': _checkIn!.toIso8601String(),
        'check_out_date': _checkOut!.toIso8601String(),
        'number_of_rooms': _roomsCount,
        'customer_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      },
    );
    try {
      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réservation confirmée'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Réserver - ${widget.hotel.name}'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: _isLoadingRooms
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._rooms.map((room) => Card(
              color: _selectedRoom == room ? Colors.green.shade50 : null,
              child: ListTile(
                title: Text(room.roomType),
                subtitle: Text('${room.pricePerNight} €/nuit'),
                trailing: Radio<Room>(value: room, groupValue: _selectedRoom, onChanged: (r) => setState(() => _selectedRoom = r)),
              ),
            )),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _dateTile('Arrivée', _checkIn, (d) => setState(() => _checkIn = d))),
              const SizedBox(width: 16),
              Expanded(child: _dateTile('Départ', _checkOut, (d) => setState(() => _checkOut = d))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              const Text('Chambres :'),
              IconButton(onPressed: () => setState(() => _roomsCount = _roomsCount > 1 ? _roomsCount - 1 : 1), icon: const Icon(Icons.remove)),
              Text('$_roomsCount'),
              IconButton(onPressed: () => setState(() => _roomsCount++), icon: const Icon(Icons.add)),
            ]),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nom complet', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _book, child: const Text('Confirmer la réservation')),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime? date, Function(DateTime) onSelect) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [Icon(Icons.calendar_today, size: 16), const SizedBox(width: 8), Text(date != null ? '${date.day}/${date.month}/${date.year}' : label)]),
      ),
    );
  }
}