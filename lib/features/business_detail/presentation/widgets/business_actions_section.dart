import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/cinema_list_screen.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/mall_stores_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/restaurant_menu_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/spa_reservation_modal.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/travel_agency_modal.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'online_order/hotel_reservation_modal.dart';
import 'online_order/menu_section.dart';
import 'online_order/reservation_modal.dart';
import 'online_order/boutique_detial.dart';
import 'online_order/car_rental_modal.dart';

class BusinessActionsSection extends StatelessWidget {
  final UIBusiness uiBusiness;

  const BusinessActionsSection({super.key, required this.uiBusiness});

  @override
  Widget build(BuildContext context) {
    final business = uiBusiness.business;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Actions",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 16,
              children: [
                _buildActionButton(
                  context,
                  icon: "assets/icons/share-circle-svgrepo-com.svg",
                  label: "Partager",
                  onTap: () => _shareBusiness(context),
                ),
                _buildActionButton(
                  context,
                  icon: "assets/icons/phone-intercom-svgrepo-com.svg",
                  label: "Appeler",
                  onTap: () => _callBusiness(context, business),
                ),
                _buildActionButton(
                  context,
                  icon: "assets/icons/map-arrow-square-svgrepo-com.svg",
                  label: "Y aller",
                  onTap: () => _navigateToBusiness(context, business),
                ),
                if (business.type == BusinessType.restaurant &&
                    business.specificData['hasDelivery'] == true)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/delivery-svgrepo-com.svg",
                    label: "Commander",
                    onTap: () => _orderFood(context, business),
                  ),
                if (business.type == BusinessType.restaurant &&
                    business.specificData['canReserve'] == true)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/calendar-date-svgrepo-com (1).svg",
                    label: "Réserver table",
                    onTap: () => showRestaurantReservationModal(context, business),
                  ),
                if (business.type == BusinessType.fastFood &&
                    business.specificData['hasDelivery'] == true)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/delivery-svgrepo-com.svg",
                    label: "Commander",
                    onTap: () => _orderFood(context, business),
                  ),

                if (business.type == BusinessType.fastFood &&
                    business.specificData['hasDelivery'] == true)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/menu-food-svgrepo-com.svg",
                    label: "Menu",
                    onTap: () => _showMenu(context, business),
                  ),
                if (business.type == BusinessType.restaurant &&
                    business.specificData['hasDelivery'] == true)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/menu-food-svgrepo-com.svg",
                    label: "Menu",
                    onTap: () => _showMenu(context, business),
                  ),

                if (business.type == BusinessType.hotel)
                  _buildActionButton(
                    context,
                    icon:"assets/icons/bedroom-8-svgrepo-com.svg",
                    label: "Réserver chambre",
                    onTap: () => showHotelReservationModal(context, business),
                  ),
                if (business.type == BusinessType.mall)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/shop-svgrepo-com.svg",
                    label: "Voir boutiques",
                    onTap: () => _showMallStores(context, business),
                  ),
                if (business.type == BusinessType.carRental)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/car-svgrepo-com.svg",
                    label: "Réserver véhicule",
                    onTap: () => showCarRentalModal(context, business),
                  ),
                if (business.type == BusinessType.travelAgency)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/car-svgrepo-com.svg",
                    label: "Réserver véhicule",
                    onTap: () => showTravelReservationModal(context, business),
                  ),
                if (business.type == BusinessType.spa)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/spa-svgrepo-com.svg", // ou Icons.spa
                    label: "Réserver soin",
                    onTap: () => showSpaReservationModal(context, business),
                  ),
                if (business.type == BusinessType.cinema)
                  _buildActionButton(
                    context,
                    icon: "assets/icons/movie-svgrepo-com.svg", // ou Icons.movie
                    label: "Voir films",
                    onTap: () {
                      final movies = business.specificData['movies'] as List? ?? [];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CinemaListScreen(
                            cinema: business,
                            movies: movies,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: uiBusiness.categoryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                icon,
                colorFilter: ColorFilter.mode(
                  uiBusiness.categoryColor,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onTap,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _shareBusiness(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité de partage à implémenter')),
    );
  }

  void _callBusiness(BuildContext context, Business business) {
    if (business.phone.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appeler ${business.phone}')),
      );
    }
  }

  void _navigateToBusiness(BuildContext context, Business business) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers le business')),
    );
  }

  void _orderFood(BuildContext context, Business business) {
    final menuItemsData = business.specificData['menuItems'];

    if (menuItemsData != null && menuItemsData is List) {
      // Cas 1 : la liste contient déjà des objets MenuItem (données mockées)
      if (menuItemsData.isNotEmpty && menuItemsData.first is MenuItem) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MenuSection(menuItems: menuItemsData.cast<MenuItem>(), uiBusiness: uiBusiness, business: business,),
          ),
        );
        return;
      }
      // Cas 2 : la liste contient des Maps (données venant d'une API par exemple)
      else {
        try {
          final List<MenuItem> menuItems = _convertToMenuItemList(menuItemsData);
          if (menuItems.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MenuSection(menuItems: menuItems, uiBusiness: uiBusiness, business: business,),
              ),
            );
            return;
          }
        } catch (e) {
          print('Erreur de conversion des menuItems: $e');
        }
      }
    }

    // Si aucun cas n'a fonctionné, afficher le message d'erreur
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menu non disponible pour ce restaurant'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showMenu(BuildContext context, Business business) {
    final menuItemsData = business.specificData['menuItems'];
    if (menuItemsData != null && menuItemsData is List) {
      List<MenuItem> menuItems = [];
      if (menuItemsData.isNotEmpty && menuItemsData.first is MenuItem) {
        menuItems = menuItemsData.cast<MenuItem>();
      } else {
        try {
          menuItems = _convertToMenuItemList(menuItemsData);
        } catch (e) {
          print(e);
        }
      }
      if (menuItems.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantMenuPage(
              menuItems: menuItems,
              restaurantId: business.id,
              restaurantName: business.name,
            ),
          ),
        );
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu non disponible')),
    );
  }
  void _showMallStores(BuildContext context, Business business) {
    if (business.stores != null && business.stores!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MallStoresPage(
            stores: business.stores!,
            mallName: business.name,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune boutique disponible pour le moment'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }


  List<MenuItem> _convertToMenuItemList(List<dynamic> data) {
    return data.map((item) {
      if (item is Map<String, dynamic>) {
        return MenuItem(
          itemName: item['itemName'] as String,
          price: (item['price'] as num).toDouble(),
          itemCategory: item['itemCategory'] as String,
          imageUrl: item['imageUrl'] as String,
          rating: (item['rating'] as num).toDouble(),
          description: item['description'] as String,
          ingredients: List<String>.from(item['ingredients'] as List),
        );
      } else {
        throw Exception('Type d\'élément de menu non supporté: ${item.runtimeType}');
      }
    }).toList();
  }
}
