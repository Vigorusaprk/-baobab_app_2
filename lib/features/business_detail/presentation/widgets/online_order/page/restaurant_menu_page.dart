import 'package:baobabe_0_2/features/business_detail/presentation/widgets/menu_cards.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:flutter_svg/svg.dart';

class RestaurantMenuPage extends StatelessWidget {
  final List<MenuItem> menuItems;
  final String? restaurantId;
  final String? restaurantName;

  const RestaurantMenuPage({
    super.key,
    required this.menuItems,
    this.restaurantId,
    this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Regrouper les plats par catégorie
    final Map<String, List<MenuItem>> groupedItems = {};
    for (var item in menuItems) {
      groupedItems.putIfAbsent(item.itemCategory, () => []).add(item);
    }
    final categories = groupedItems.keys.toList();

    // Si le menu est vide, on affiche un état d'erreur simple hors du contrôleur
    if (menuItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.secondaryLight,
        appBar: _buildSimpleAppBar(context),
        body: _buildEmptyState(),
      );
    }

    // 2. On enveloppe le tout dans un DefaultTabController pour gérer l'état de la navigation haute
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimens.BORDER_RADIUS_30),
              topRight: Radius.circular(AppDimens.BORDER_RADIUS_30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          // 4. Utilisation de TabBarView : change de contenu selon la catégorie sélectionnée en haut
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimens.BORDER_RADIUS_30),
              topRight: Radius.circular(AppDimens.BORDER_RADIUS_30),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:45, right: 10, left: 10),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondaryLight,
                              AppColors.secondaryDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.primaryLight,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/menu-food-svgrepo-com.svg',
                            height: 35,
                            colorFilter: const ColorFilter.mode(
                              AppColors.secondaryLight,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: AppDimens.PADDING_12),
                          const Text(
                            'Notre Menu',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFontFamily,
                              fontSize: 24,
                              fontWeight: AppFonts.bold,
                              color: AppColors.secondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryDark, // Couleur de fond sur toute la TabBar
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.transparent, // Retrait de l'indicateur par défaut
                      labelColor: AppColors.primary, // Couleur du texte actif
                      unselectedLabelColor: AppColors.primaryDark.withOpacity(0.6),
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
                Expanded(
                  child: TabBarView(
                    children: categories.map((category) {
                      final items = groupedItems[category]!;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, idx) =>
                            RestaurantInfoBigCard(item: items[idx]),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSimpleAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.secondaryLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.scaffoldBackground),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimens.BORDER_RADIUS_30),
          topRight: Radius.circular(AppDimens.BORDER_RADIUS_30),
        ),
      ),
      child: const Center(
        child: Text(
          'Aucun menu disponible',
          style: TextStyle(fontFamily: AppFonts.primaryFontFamily),
        ),
      ),
    );
  }
}

