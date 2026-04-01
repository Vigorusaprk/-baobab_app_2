import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/movie.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showCinemaReservationModal(
    BuildContext context,
    Business cinema,
    Movie movie,
    Showtime showtime,
    ) {
  final bloc = context.read<BusinessDetailBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => BlocProvider.value(
      value: bloc,
      child: _CinemaSheet(
        cinema: cinema,
        movie: movie,
        showtime: showtime,
      ),
    ),
  );
}

class _CinemaSheet extends StatefulWidget {
  final Business cinema;
  final Movie movie;
  final Showtime showtime;

  const _CinemaSheet({
    required this.cinema,
    required this.movie,
    required this.showtime,
  });

  @override
  State<_CinemaSheet> createState() => _CinemaSheetState();
}

class _CinemaSheetState extends State<_CinemaSheet> {
  int _tickets = 1;
  bool _isLoading = false;

  void _book() async {
    // Récupérer l'utilisateur connecté
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter'), backgroundColor: Colors.orange),
      );
      Navigator.pop(context);
      return;
    }
    final userId = authState.user.id;

    setState(() => _isLoading = true);

    final reservation = ReservationModel(
      businessId: widget.cinema.id,
      userId: userId,
      type: "cinema",
      reservationDate: widget.showtime.startTime,
      totalAmount: widget.showtime.price * _tickets,
      details: {
        "movie_id": widget.movie.id,
        "movie_title": widget.movie.title,
        "showtime_id": widget.showtime.id,
        "tickets_count": _tickets,
        "hall": widget.showtime.room,
        "price_per_ticket": widget.showtime.price,
      },
    );

    try {
      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation confirmée !'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = '${widget.showtime.startTime.hour.toString().padLeft(2, '0')}:${widget.showtime.startTime.minute.toString().padLeft(2, '0')}';
    final formattedDate = '${widget.showtime.startTime.day}/${widget.showtime.startTime.month}/${widget.showtime.startTime.year}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.movie.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$formattedDate à $formattedTime - ${widget.showtime.room}',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          const Text("Sélectionnez vos places", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Nombre de places"),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _tickets--),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text("$_tickets", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => setState(() => _tickets++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '${(widget.showtime.price * _tickets).toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _isLoading ? null : _book,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Payer maintenant"),
            ),
          ),
        ],
      ),
    );
  }
}