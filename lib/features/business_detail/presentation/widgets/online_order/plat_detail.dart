import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:flutter/material.dart';

class PlatDetail extends StatelessWidget {
  final MenuItem menuItem;
  const PlatDetail({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(elevation: 0, backgroundColor: AppColors.primary, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(menuItem.imageUrl, height: 300, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 24),
            Text(menuItem.itemName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(menuItem.itemCategory, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 16),
            Text(menuItem.description, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${menuItem.price} \$", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.scaffoldBackground)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.scaffoldBackground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {},
            child: const Text("Ajouter au panier", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}