import 'dart:ui';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart' show AppFonts;
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/plat_detail.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/order/domain/entities/cart_item.dart';
import 'package:baobabe_0_2/features/order/presentation/bloc/cart_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class MenuSection extends StatelessWidget {
  final List<MenuItem> menuItems;
  final String? restaurantId;
  final String? restaurantName;
  final BusinessType? restaurantType;
  final UIBusiness uiBusiness;
  final Business business;

  const MenuSection({
    super.key,
    required this.menuItems,
    this.restaurantId,
    this.restaurantName,
    this.restaurantType,
    required this.business,
    required this.uiBusiness,
  });

  @override
  Widget build(BuildContext context) {
    final groupedItems = <String, List<MenuItem>>{};
    for (var item in menuItems) {
      groupedItems.putIfAbsent(item.itemCategory, () => []).add(item);
    }
    final categories = groupedItems.keys.toList();

    return BlocProvider(
      create: (context) => CartCubit(),
      child: DefaultTabController(
        length: categories.length, // OBLIGATOIRE pour synchroniser la TabBar et le TabBarView
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 45, right: 10, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/delivery-svgrepo-com.svg',
                          height: 35,
                          colorFilter: const ColorFilter.mode(
                            AppColors.secondaryLight,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Commander',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryLight,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<CartCubit, CartState>(
                      builder: (context, state) {
                        final totalItems = context.read<CartCubit>().totalItems;
                        return Stack(
                          clipBehavior: Clip.none,
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
                                icon: const Icon(Icons.shopping_cart, color: AppColors.primary,),
                                onPressed: () {
                                  final cartCubit = context.read<CartCubit>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: cartCubit,
                                        child: CartPage(
                                          restaurantId: restaurantId,
                                          restaurantName: restaurantName,
                                          restaurantType: restaurantType,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (totalItems > 0)
                              Positioned(
                                right: 0.50,
                                top: 0.50,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    '$totalItems',
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildContent(context, categories, groupedItems),
                ),
              ),
            ],
          ),
        ),
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
                  return _buildMenuItemCard(context, item); // AJOUT du mot-clé return ici !
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemCard(BuildContext context, MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlatDetail(
                menuItem: item,
                restaurantId: restaurantId,
                restaurantName: restaurantName,
                restaurantType: restaurantType,
                isOrderMode: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: 380,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16), // Ajout pour éviter que l'image ne dépasse les angles de la carte
            child: Stack(
              children: [
                _buildBackgroundOrbes(item),

                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondaryLight.withOpacity(0.7),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                Container(
                  decoration: const BoxDecoration( // Ajout du const
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondaryLight,
                        AppColors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            '${item.price.toStringAsFixed(2)} €',
                            style: const TextStyle( // Ajout du const
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle( // Ajout du const
                          color: AppColors.secondaryDark,
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row( // Nettoyage du Container inutile autour du Row
                            children: [
                              SvgPicture.asset(
                                "assets/icons/delivery-svgrepo-com.svg",
                                height: 20,
                                width: 20,
                                colorFilter: const ColorFilter.mode( // Ajout du const
                                  AppColors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "20-30 min",
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              final cart = context.read<CartCubit>();
                              cart.addItem(CartItem(menuItem: item, quantity: 1));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.itemName} ajouté au panier', style: const TextStyle(color: Colors.black)),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient( // Ajout du const
                                  colors: [
                                    AppColors.secondaryLight,
                                    AppColors.secondaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Row( // Ajout du const
                                children: [
                                  Text("Ajouté au panier", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  SizedBox(width: 5),
                                  Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 24),
                                ],
                              ),
                            ),
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

  Widget _buildBackgroundOrbes(dynamic item) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: item.imageUrl.startsWith('http')
              ? Image.network(
            item.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          )
              : Image.asset(
            item.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() => Container(
    height: 180,
    color: Colors.grey[200],
    width: double.infinity,
    child: Stack(
      children: [
        Positioned(
            right: 10,
            bottom: 5,
            child: const Icon(Icons.fastfood, color: Colors.grey, size:150)
        ),
      ],
    ),
  );
}