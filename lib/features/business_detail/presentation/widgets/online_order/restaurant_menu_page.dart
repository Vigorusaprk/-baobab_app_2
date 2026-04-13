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
    // Regrouper les plats par catégorie (item_category en SQL)
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/menu-food-svgrepo-com.svg',
              height: 35,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
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
                color: AppColors.primary,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                category,
                style: const TextStyle(
                  fontFamily: AppFonts.primaryFontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
              itemBuilder: (context, idx) =>
                  _buildMenuItemCard(context, items[idx]),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildMenuItemCard(BuildContext context, MenuItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlatDetail(
            menuItem: item,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            isOrderMode: false,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: item.imageUrl.startsWith('http')
                    ? Image.network(
                        item.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : Image.asset(
                        item.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(2)} \$',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() => Container(
    color: Colors.grey[200],
    width: double.infinity,
    child: const Icon(Icons.fastfood, color: Colors.grey, size: 50,),
  );
}
