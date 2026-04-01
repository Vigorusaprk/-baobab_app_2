import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';

class SpaSheet extends StatefulWidget {
  final Business business;
  const SpaSheet({super.key, required this.business});

  @override
  State<SpaSheet> createState() => _SpaSheetState();
}

class _SpaSheetState extends State<SpaSheet> {
  final List<String> _selectedTreatments = [];
  bool _isLoading = false;

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

    setState(() => _isLoading = true);

    final reservation = ReservationModel(
      businessId: widget.business.id,
      userId: userId,
      type: "spa",
      reservationDate: DateTime.now(),
      totalAmount: 0.0,
      details: {
        "treatments": _selectedTreatments,
        "therapist": "Any",
      },
    );

    try {
      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soin réservé'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text("Réserver un soin", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                // Liste des soins (CheckboxListTile)
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _confirm,
              child: const Text("Réserver"),
            ),
          ),
        ],
      ),
    );
  }
}