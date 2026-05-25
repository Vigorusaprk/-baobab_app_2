import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BusinessHeroSection extends StatelessWidget {
  final UIBusiness uiBusiness;

  const BusinessHeroSection({super.key, required this.uiBusiness});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: ReviewApiService(dio: Injector.get<Dio>()).getReviews(uiBusiness.business.id),
      builder: (context, snapshot) {
        // Calcul de la note moyenne et du nombre d'avis
        double rating;
        int reviewCount;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final reviews = snapshot.data!;
          reviewCount = reviews.length;
          rating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviewCount;
        } else {
          rating = uiBusiness.business.rating;
          reviewCount = uiBusiness.business.reviewCount;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              // Logo circulaire
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: uiBusiness.categoryColor.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    )
                  ],
                  border: Border.all(color: uiBusiness.categoryColor.withOpacity(0.2), width: 3),
                ),
                child: Icon(uiBusiness.categoryIcon, size: 45, color: uiBusiness.categoryColor),
              ),
              const SizedBox(height: 20),
              // Nom du commerce
              Text(
                uiBusiness.business.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              // Badges (note et statut)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadge(
                    icon: Icons.star_rounded,
                    label: "$rating ($reviewCount ${reviewCount > 1 ? 'avis' : 'avis'})",
                    color: Colors.amber[700]!,
                  ),
                  const SizedBox(width: 12),
                  _buildBadge(
                    icon: Icons.circle,
                    label: uiBusiness.isOpen ? 'OUVERT' : 'FERMÉ',
                    color: uiBusiness.isOpen ? Colors.green : Colors.red,
                    isStatus: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    bool isStatus = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isStatus ? 8 : 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}