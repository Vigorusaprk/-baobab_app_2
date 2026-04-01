import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:flutter/material.dart';

void showTravelReservationModal(BuildContext context, Business business) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TravelSheet(business: business),
  );
}

class _TravelSheet extends StatefulWidget {
  final Business business;
  const _TravelSheet({required this.business});

  @override
  State<_TravelSheet> createState() => _TravelSheetState();
}

class _TravelSheetState extends State<_TravelSheet> {
  String? _destination;

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
          Text("Réserver un voyage", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            hint: const Text("Choisir une destination"),
            items: const [
              DropdownMenuItem(value: "Paris", child: Text("Paris")),
              DropdownMenuItem(value: "Kinshasa", child: Text("Kinshasa")),
            ],
            onChanged: (v) => _destination = v,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () {
                // Logique ReservationModel ici...
                Navigator.pop(context);
              },
              child: const Text("Réserver mon billet"),
            ),
          ),
        ],
      ),
    );
  }
}