import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'business_contact_section.dart';
import 'business_hours_section.dart';

class BusinessInfoSection extends StatelessWidget {
  final Business business;

  const BusinessInfoSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Card
          if (business.description.isNotEmpty) ...[
            _buildSectionTitle("À propos"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                business.description,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          _buildSectionTitle("Contact & Accès"),
          BusinessContactSection(business: business),

          const SizedBox(height: 24),

          _buildSectionTitle("Horaires d'ouverture"),
          BusinessHoursSection(business: business),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF254D32),
        ),
      ),
    );
  }
}