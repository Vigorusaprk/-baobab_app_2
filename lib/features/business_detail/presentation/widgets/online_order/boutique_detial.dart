import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/common/rating_widget.dart';
import 'package:flutter/material.dart';

class BoutiqueDetial extends StatelessWidget {
  final Business businessModel;
  const BoutiqueDetial({super.key, required this.businessModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: _buildCircleBtn(context, Icons.arrow_back_ios_new_rounded),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(businessModel.bgImg, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(businessModel.name,
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1)),
                        ),
                        RatingWidget(rating: businessModel.rating, reviewCount: businessModel.reviewCount),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFF254D32)),
                        const SizedBox(width: 4),
                        Text(businessModel.address, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
                    const Text("À propos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(businessModel.description, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(BuildContext context, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.black, size: 18), onPressed: () => Navigator.pop(context)),
    );
  }
}