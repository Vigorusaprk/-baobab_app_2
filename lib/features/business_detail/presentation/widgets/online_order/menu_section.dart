import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/plat_detail.dart';
import 'package:flutter/material.dart';

class MenuSection extends StatelessWidget {
  final List<MenuItem> menuItems;
  const MenuSection({super.key, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    // Regroupement des plats par catégorie
    final Map<String, List<MenuItem>> groupedItems = {};
    for (var item in menuItems) {
      groupedItems.putIfAbsent(item.itemCategory, () => []).add(item);
    }
    final categories = groupedItems.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // AppBar avec image de couverture
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Le Menu",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/restaurant_cover.jpg', // Remplacez par votre image
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primary.withOpacity(0.8),
                      child: const Icon(Icons.restaurant, size: 80, color: Colors.white),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          // Contenu
          if (categories.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Menu non disponible",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            for (var category in categories) ...[
              // Titre de catégorie
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              // Liste des plats de la catégorie
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final menu = groupedItems[category]![index];
                      return _buildMenuItem(context, menu);
                    },
                    childCount: groupedItems[category]!.length,
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem menu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlatDetail(menuItem: menu)),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du plat avec gestion d'erreur
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    menu.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Détails du plat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        menu.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Prix et note
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${menu.price.toStringAsFixed(2)} \$",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          if (menu.rating > 0)
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  menu.rating.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}