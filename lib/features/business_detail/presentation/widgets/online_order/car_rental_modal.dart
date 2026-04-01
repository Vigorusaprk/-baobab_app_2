import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';

class CarRentalSheet extends StatefulWidget {
  final Business business;
  const CarRentalSheet({super.key, required this.business});

  @override
  State<CarRentalSheet> createState() => _CarRentalSheetState();
}

class _CarRentalSheetState extends State<CarRentalSheet> {
  final _data = CarRentalData();
  bool _isLoading = false;

  void _confirm() async {
    if (_data.rentalStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date de début'), backgroundColor: Colors.orange),
      );
      return;
    }

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
      type: "car_rental",
      reservationDate: _data.rentalStartDate!,
      totalAmount: 0.0,
      details: {
        "vehicle_type": _data.selectedVehicleType,
        "days": _data.rentalDays,
        "with_driver": _data.withDriver,
        "insurance": _data.includeInsurance,
      },
    );

    try {
      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location confirmée'), backgroundColor: Colors.green),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text("Louer un véhicule", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 20),
          // Vos sélecteurs de date et types de véhicules
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _isLoading ? null : _confirm,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Confirmer la location"),
            ),
          ),
        ],
      ),
    );
  }
}

class CarRentalData {
  String? selectedVehicleType;
  DateTime? rentalStartDate;
  DateTime? rentalEndDate;
  bool withDriver = false;
  bool includeInsurance = true;

  int get rentalDays {
    if (rentalStartDate != null && rentalEndDate != null) {
      final days = rentalEndDate!.difference(rentalStartDate!).inDays;
      return days < 1 ? 1 : days;
    }
    return 1;
  }
}