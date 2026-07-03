import 'dart:ui';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart' show AppFonts;
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/plat_detail.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/order/domain/entities/cart_item.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
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
          backgroundColor: AppColors.canvasBackground,
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
                        border: Border.all(width: 3, color: AppColors.secondary)
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.secondary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/delivery-svgrepo-com.svg',
                          height: 35,
                          colorFilter: const ColorFilter.mode(
                            AppColors.secondary,
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
                            color: AppColors.secondary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<BusinessDetailBloc, BusinessDetailState>(
                      builder: (context, state) {
                        // Calcul du total des articles via la liste du bloc
                        final totalItems = state.cartItems.fold(0, (sum, item) => sum + item.quantity);

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 3, color: AppColors.secondary)
                              ),
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  "assets/icons/shopping-cart.svg",
                                  width: 28,
                                  height: 28,
                                  colorFilter: const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn),
                                ),
                                onPressed: () {
                                  // On récupère le bloc existant
                                  final bloc = context.read<BusinessDetailBloc>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: bloc, // On passe l'instance existante à la nouvelle route
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
                                  padding: const EdgeInsets.all(7),
                                  decoration: const BoxDecoration(
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // 2. Ombre plus prononcée
                color: Colors.black.withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Garde les orbes existants
                _buildBackgroundOrbes(item),

                // 3. Verre dépoli adapté au fond sombre
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3), // noir transparent
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15), // bordure claire très fine
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // 4. Overlay dégradé subtil sur la gauche (effet de lumière)
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white10, // touche de brillance
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),

                // --- CONTENU (structure inchangée, couleurs adaptées) ---
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
                              color: AppColors.accent100, // Blanc
                              height: 1.2,
                            ),
                          ),
                          Text(
                            '${item.price.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              color: AppColors.accent50, // Blanc
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
                        style: const TextStyle(
                          color: AppColors.accent50, // Gris clair
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/delivery-svgrepo-com.svg",
                                height: 20,
                                width: 20,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.accent50, // Icône blanche
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "20-30 min",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  fontSize: 12,
                                  color: AppColors.accent50,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                        GestureDetector(
                              onTap: () {
                                // 1. On récupère le bloc existant
                                final bloc = context.read<BusinessDetailBloc>();

                                // 2. On crée l'objet OrderItem (ajustez selon vos champs si nécessaire)
                                final newItem = OrderItem(
                                  menuItemId: item.id.toString(),
                                  name: item.itemName,
                                  price: item.price,
                                  quantity: 1,
                                );

                                // 3. On déclenche l'événement AddToCart
                                bloc.add(AddToCart(newItem));

                                // 4. Feedback utilisateur
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${item.itemName} ajouté au panier',
                                        style: const TextStyle(color: Colors.black)),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.secondary,
                                  ),
                                );
                              },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                // 5. Bouton en dégradé doré pour contraster sur fond sombre
                                gradient:  LinearGradient(
                                  colors: [
                                    AppColors.secondary300,
                                    AppColors.secondary600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    "Ajouté au panier",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(width: 5),
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
    decoration: BoxDecoration(
      // 1. NOUVEAU STYLE : Dégradé sombre élégant (comme la carte earnings)
      gradient: const LinearGradient(
        colors: [Color(0xFF1E2A3E), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    height: 180,
    width: double.infinity,
    child: Stack(
      children: [
        Positioned(
            right: 10,
            bottom: 5,
            child: const Icon(Icons.fastfood, color: Colors.white, size:150)
        ),
      ],
    ),
  );
}