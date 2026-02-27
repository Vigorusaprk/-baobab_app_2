import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/plat_detail.dart';
import 'package:flutter/material.dart';

class MenuSection extends StatelessWidget {
  final List<MenuItem> menuItems;
  const MenuSection({super.key, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text("Le Menu", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF254D32))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: menuItems.isEmpty ? _buildEmptyState() : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: menuItems.length,
        itemBuilder: (context, index) => _buildMenuItem(context, menuItems[index]),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem menu) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlatDetail(menuItem: menu))),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(menu.imageUrl, width: 85, height: 85, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(menu.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 8),
                  Text("${menu.price} \$", style: const TextStyle(color: Color(0xFF254D32), fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_rounded, color: Color(0xFF254D32), size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("Menu non disponible"));
}