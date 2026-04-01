import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/room.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RoomDetailPage extends StatefulWidget {
  final Business hotel;
  final Room room;

  const RoomDetailPage({super.key, required this.hotel, required this.room});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _roomsCount = 1;
  int _adults = 2;
  int _children = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(DateTime? current, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? (isCheckIn ? DateTime.now() : DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut != null && _checkOut!.isBefore(picked)) {
            _checkOut = null;
          }
        } else {
          if (_checkIn != null && picked.isAfter(_checkIn!)) {
            _checkOut = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La date de départ doit être après la date d\'arrivée'), backgroundColor: Colors.orange),
            );
          }
        }
      });
    }
  }

  int get nights {
    if (_checkIn != null && _checkOut != null) {
      return _checkOut!.difference(_checkIn!).inDays;
    }
    return 0;
  }

  double get totalPrice {
    return widget.room.pricePerNight * nights * _roomsCount;
  }

  void _book() async {
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

    // Récupérer l'utilisateur connecté
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      context.go('/login');
      return;
    }
    final userId = authState.user.id;

    final nights = _checkOut!.difference(_checkIn!).inDays;
    final totalAmount = widget.room.pricePerNight * nights * _roomsCount;

    final reservation = ReservationModel(
      businessId: widget.hotel.id,
      userId: userId,
      type: "hotel",
      reservationDate: DateTime.now(),
      totalAmount: totalAmount,
      details: {
        "room_id": widget.room.id,
        "room_type": widget.room.roomType,
        "check_in": _checkIn!.toIso8601String(),
        "check_out": _checkOut!.toIso8601String(),
        "nights": nights,
        "rooms": _roomsCount,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.room.roomType),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                image: widget.room.images != null && widget.room.images!.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(widget.room.images!.first),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: widget.room.images == null || widget.room.images!.isEmpty
                  ? const Icon(Icons.hotel, size: 80, color: Colors.grey)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.room.roomType,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.room.pricePerNight.toStringAsFixed(2)} € / nuit',
                    style: TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Capacité: ${widget.room.capacity} personnes'),
                  const SizedBox(height: 4),
                  Text('Disponibles: ${widget.room.availableQuantity} chambres'),
                  if (widget.room.description != null) ...[
                    const SizedBox(height: 16),
                    const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.room.description!),
                  ],
                  if (widget.room.amenities != null && widget.room.amenities!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Équipements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.room.amenities!.entries.map((entry) {
                        if (entry.value == true) {
                          return Chip(
                            label: Text(entry.key),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          );
                        }
                        return const SizedBox();
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text('Réservation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: _dateTile(
                          label: 'Arrivée',
                          date: _checkIn,
                          onTap: () => _selectDate(_checkIn, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateTile(
                          label: 'Départ',
                          date: _checkOut,
                          onTap: () => _selectDate(_checkOut, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Nombre de chambres
                  _counterRow('Chambres', _roomsCount, (v) => setState(() => _roomsCount = v), 1, widget.room.availableQuantity),
                  const SizedBox(height: 16),
                  _counterRow('Adultes', _adults, (v) => setState(() => _adults = v), 1, 10),
                  const SizedBox(height: 16),
                  _counterRow('Enfants', _children, (v) => setState(() => _children = v), 0, 5),
                  const SizedBox(height: 24),
                  // Informations client
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
                  // Total et bouton
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '${totalPrice.toStringAsFixed(2)} €',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
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
          ],
        ),
      ),
    );
  }

  Widget _dateTile({required String label, required DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
}