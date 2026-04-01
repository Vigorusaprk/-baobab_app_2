import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';

class TourismSheet extends StatefulWidget {
  final Business business;
  const TourismSheet({super.key, required this.business});

  @override
  State<TourismSheet> createState() => _TourismSheetState();
}

class _TourismSheetState extends State<TourismSheet> {
  int _participants = 1;

  void _confirm() async {
    // Récupérer l'utilisateur connecté
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter'), backgroundColor: Colors.orange),
      );
      return;
    }
    final userId = authState.user.id;

    final reservation = ReservationModel(
      businessId: widget.business.id,
      userId: userId,
      type: "tourism",
      reservationDate: DateTime.now(),
      totalAmount: 0.0,
      details: {
        "participants": _participants,
        "activities": ["Visite guidée"],
      },
    );

    try {
      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excursion confirmée'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Planifier votre visite", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 30),
          // Contrôleur de participants
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _confirm,
              child: const Text("Confirmer l'excursion"),
            ),
          ),
        ],
      ),
    );
  }
}