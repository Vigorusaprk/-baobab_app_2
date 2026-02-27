import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class BusinessCommentsSection extends StatelessWidget {
  final Business business;

  const BusinessCommentsSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    if (business.reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Avis clients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF254D32))),
              TextButton(onPressed: () {}, child: const Text("Voir tout")),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: business.reviews.take(3).length,
          itemBuilder: (context, index) {
            final review = business.reviews[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(review.date.toString(), style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text("${review.rating}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(review.comment, style: TextStyle(color: Colors.grey[800], height: 1.4)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}