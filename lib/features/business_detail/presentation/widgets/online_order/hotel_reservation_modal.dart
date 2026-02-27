import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

void showHotelReservationModal(BuildContext context, Business business) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          const Text("Détails du séjour", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),

          _buildInfoTile(Icons.hotel_outlined, "Type de chambre", "Suite Junior"),
          _buildInfoTile(Icons.calendar_today_outlined, "Dates", "12 Jan - 15 Jan (3 nuits)"),
          _buildInfoTile(Icons.people_outline, "Voyageurs", "2 Adultes"),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total (Taxes incluses)", style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text("1,050.00 \$", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF254D32))),
            ],
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF254D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Réserver maintenant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildInfoTile(IconData icon, String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: const Color(0xFF254D32)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        )
      ],
    ),
  );
}