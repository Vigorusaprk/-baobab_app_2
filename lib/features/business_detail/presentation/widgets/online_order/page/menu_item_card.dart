import 'dart:ui';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/plat_detail.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final String? restaurantId;
  final String? restaurantName;
  final BusinessType? restaurantType;

  const MenuItemCard({
    super.key,
    required this.item,
    this.restaurantId,
    this.restaurantName,
    this.restaurantType,
  });

  @override
  Widget build(BuildContext context) {
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
                              color: AppColors.primary50, // Blanc
                              height: 1.2,
                            ),
                          ),
                          Text(
                            '${item.price.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              color: AppColors.primary50, // Blanc
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
                          color: AppColors.primary50, // Gris clair
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
                                  AppColors.primary50, // Icône blanche
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
                                  color: AppColors.primary50,
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
