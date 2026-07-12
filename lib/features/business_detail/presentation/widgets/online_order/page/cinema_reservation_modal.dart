import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/movie.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showCinemaReservationModal(
    BuildContext context, {
      required Business cinema,
      required Movie movie,
      required Showtime showtime,
    }) {
  final bloc = context.read<BusinessDetailBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => BlocProvider.value(
      value: bloc,
      child: CinemaReservationModal(
        cinema: cinema,
        movie: movie,
        showtime: showtime,
      ),
    ),
  );
}

class CinemaReservationModal extends StatefulWidget {
  final Business cinema;
  final Movie movie;
  final Showtime showtime;

  const CinemaReservationModal({
    super.key,
    required this.cinema,
    required this.movie,
    required this.showtime,
  });

  @override
  State<CinemaReservationModal> createState() => _CinemaReservationModalState();
}

class _CinemaReservationModalState extends State<CinemaReservationModal> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int _numberOfTickets = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get totalPrice => widget.showtime.price * _numberOfTickets;

  void _book() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_fullNameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir votre nom et téléphone'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final reservation = Reservation(
      id: '',
      businessId: widget.cinema.id,
      userId: authState.user.id,
      type: 'cinema',
      reservationDate: widget.showtime.startTime,
      createdAt: DateTime.now(),
      totalAmount: totalPrice,
      details: {
        'movie_id': widget.movie.id,
        'movie_title': widget.movie.title,
        'showtime_id': widget.showtime.id,
        'showtime': widget.showtime.startTime.toIso8601String(),
        'room': widget.showtime.room,
        'tickets_count': _numberOfTickets,
        'customer_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'establishment_name': widget.cinema.name,
      },
    );

    try {
      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation confirmée !'), backgroundColor: Colors.green),
      );
    } catch (e) {
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
            'Réserver ${widget.movie.title}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.showtime.startTime.day}/${widget.showtime.startTime.month}/${widget.showtime.startTime.year} à ${widget.showtime.startTime.hour}:${widget.showtime.startTime.minute.toString().padLeft(2, '0')} - ${widget.showtime.room}',
            style: const TextStyle(color: Colors.grey),
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
                    onPressed: _numberOfTickets > 1 ? () => setState(() => _numberOfTickets--) : null,
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
                onPressed: _isLoading ? null : _book,
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