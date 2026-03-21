import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/plat_detail.dart';
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
    // Regrouper les plats par catégorie
    final Map<String, List<MenuItem>> groupedItems = {};
    for (var item in menuItems) {
      groupedItems.putIfAbsent(item.itemCategory, () => []).add(item);
    }
    final categories = groupedItems.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/menu-food-svgrepo-com.svg',
              height: 35,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppDimens.PADDING_12),
            Text(
              'Notre Menu',
              style: TextStyle(
                fontFamily: AppFonts.primaryFontFamily,
                fontSize: 24,
                fontWeight: AppFonts.bold,
                color: AppColors.primary,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),

      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimens.BORDER_RADIUS_30),
            topRight: Radius.circular(AppDimens.BORDER_RADIUS_30),
          ),
        ),
        child: _buildContent(context, categories, groupedItems),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      List<String> categories,
      Map<String, List<MenuItem>> groupedItems,
      ) {
    if (menuItems.isEmpty) {
      return const Center(
        child: Text(
          'Aucun menu disponible',
          style: TextStyle(fontFamily: AppFonts.primaryFontFamily),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final items = groupedItems[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final item = items[idx];
                return _buildMenuItemCard(context, item);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildMenuItemCard(BuildContext context, MenuItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlatDetail(
              menuItem: item,
              restaurantId: restaurantId,
              restaurantName: restaurantName,
              isOrderMode: false,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  item.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.fastfood),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFontFamily,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 15,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFontFamily,
                        color: Colors.grey[600],
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}