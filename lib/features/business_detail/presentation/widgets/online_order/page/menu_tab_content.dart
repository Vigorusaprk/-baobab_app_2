import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart' show AppFonts;
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/menu_item_card.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class MenuTabContent extends StatelessWidget {
  final List<MenuItem> menuItems;
  final List<String> categories;
  final Map<String, List<MenuItem>> groupedItems;
  final String? restaurantId;
  final String? restaurantName;
  final BusinessType? restaurantType;

  const MenuTabContent({
    super.key,
    required this.menuItems,
    required this.categories,
    required this.groupedItems,
    this.restaurantId,
    this.restaurantName,
    this.restaurantType,
  });

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) {
      return const Center(
        child: Text(
          'Menu non disponible',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      );
    }

    return Column(
      children: [
        // 1. Barre de navigation stylisée avec le fond global demandé précédemment
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.secondary, // Couleur de fond sur toute la TabBar
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.transparent, // Retrait de l'indicateur par défaut
              labelColor: AppColors.accent50, // Couleur du texte actif
              unselectedLabelColor: AppColors.accent50,
              labelStyle: const TextStyle(
                fontFamily: AppFonts.primaryFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: AppFonts.primaryFontFamily,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              tabs: categories.map((category) => Tab(text: category)).toList(),
            ),
          ),
        ),

        // 2. Le TabBarView prend directement sa place dans la Column via un Expanded
        Expanded(
          child: TabBarView(
            children: categories.map((category) {
              final items = groupedItems[category]!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, idx) {
                  final item = items[idx];
                  return MenuItemCard(
                    item: item,
                    restaurantId: restaurantId,
                    restaurantName: restaurantName,
                    restaurantType: restaurantType,
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
