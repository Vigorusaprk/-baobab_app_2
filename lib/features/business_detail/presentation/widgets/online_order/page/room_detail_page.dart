import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/room.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/room_booking_summary.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/room_counter_row.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/room_date_selectors.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/room_info_header.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    final sessionUser = SessionService.instance.currentUser;
    if (sessionUser == null) {
      showAuthRequiredCard(context, message: 'Connectez-vous pour réserver cette chambre.');
      return;
    }
    final userId = sessionUser.id;

    final nights = _checkOut!.difference(_checkIn!).inDays;
    final totalAmount = widget.room.pricePerNight * nights * _roomsCount;

    final reservation = Reservation(
      id: '',
      businessId: widget.hotel.id,
      userId: userId,
      type: "hotel",
      reservationDate: DateTime.now(),
      createdAt: DateTime.now(),
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
        "establishment_name": widget.hotel.name,
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
            RoomImageHeader(room: widget.room),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoomInfoHeader(room: widget.room),
                  const SizedBox(height: 24),
                  const Text('Réservation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  RoomDateSelectors(
                    checkIn: _checkIn,
                    checkOut: _checkOut,
                    onSelectCheckIn: () => _selectDate(_checkIn, true),
                    onSelectCheckOut: () => _selectDate(_checkOut, false),
                  ),
                  const SizedBox(height: 16),
                  RoomCounterRow(
                    label: 'Chambres',
                    value: _roomsCount,
                    onChanged: (v) => setState(() => _roomsCount = v),
                    min: 1,
                    max: widget.room.availableQuantity,
                  ),
                  const SizedBox(height: 16),
                  RoomCounterRow(
                    label: 'Adultes',
                    value: _adults,
                    onChanged: (v) => setState(() => _adults = v),
                    min: 1,
                    max: 10,
                  ),
                  const SizedBox(height: 16),
                  RoomCounterRow(
                    label: 'Enfants',
                    value: _children,
                    onChanged: (v) => setState(() => _children = v),
                    min: 0,
                    max: 5,
                  ),
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
                  RoomBookingSummary(totalPrice: totalPrice, onBook: _book),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
