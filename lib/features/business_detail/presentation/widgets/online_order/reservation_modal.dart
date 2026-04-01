import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';

class RestaurantReservationSheet extends StatefulWidget {
  final Business business;
  const RestaurantReservationSheet({super.key, required this.business});

  @override
  State<RestaurantReservationSheet> createState() => _RestaurantSheetState();
}

class _RestaurantSheetState extends State<RestaurantReservationSheet> {
  final _data = ReservationData();
  bool _isLoading = false;

  // Sélecteur de date – sans builder personnalisé
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _data.date = picked);
    }
  }

  // Sélecteur d'heure
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _data.time = picked);
    }
  }

  void _confirm() async {
    if (_data.date == null || _data.time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date et une heure'), backgroundColor: Colors.orange),
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

    final fullDateTime = DateTime(
      _data.date!.year, _data.date!.month, _data.date!.day,
      _data.time!.hour, _data.time!.minute,
    );

    final reservation = ReservationModel(
      businessId: widget.business.id,
      userId: userId,
      type: "restaurant",
      reservationDate: fullDateTime,
      totalAmount: _data.subtotal,
      details: {
        "table_number": _data.selectedTable,
        "guests": _data.numberOfPeople,
        "customer_name": _data.fullName,
        "phone": _data.phoneNumber,
      },
    );

    try {
      context.read<BusinessDetailBloc>().add(MakeReservation(reservation));
      Navigator.pop(context);
      _showSuccess();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Table réservée !"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée de fermeture
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // Titre
          Text(
            "Réserver une table",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Nom complet
          TextField(
            decoration: InputDecoration(
              labelText: "Nom complet",
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onChanged: (val) => _data.fullName = val,
          ),
          const SizedBox(height: 15),

          // Téléphone
          TextField(
            decoration: InputDecoration(
              labelText: "Numéro de téléphone",
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (val) => _data.phoneNumber = val,
          ),
          const SizedBox(height: 15),

          // Date
          GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Date",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                controller: TextEditingController(
                  text: _data.date != null
                      ? "${_data.date!.day}/${_data.date!.month}/${_data.date!.year}"
                      : "",
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Heure
          GestureDetector(
            onTap: _selectTime,
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Heure",
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                controller: TextEditingController(
                  text: _data.time != null
                      ? "${_data.time!.hour.toString().padLeft(2, '0')}:${_data.time!.minute.toString().padLeft(2, '0')}"
                      : "",
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Nombre de personnes
          Row(
            children: [
              const Text("Nombre de personnes :"),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() {
                  if (_data.numberOfPeople > 1) _data.numberOfPeople--;
                }),
              ),
              Text(
                "${_data.numberOfPeople}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _data.numberOfPeople++),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Bouton de confirmation
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _isLoading ? null : _confirm,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Confirmer la réservation"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ReservationData {
  String? selectedTable;
  String? fullName;
  String? phoneNumber;
  DateTime? date;
  TimeOfDay? time;
  int numberOfPeople = 2;
  double subtotal = 0.0;
}