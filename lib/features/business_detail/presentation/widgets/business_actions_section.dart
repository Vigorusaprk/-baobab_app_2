import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/car_rental_modal.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/cinema_list_screen.dart';
// ✅ Import de la page de liste des chambres
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/hotel_rooms_list_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/reservation_modal.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/restaurant_menu_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/menu_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/spa_reservation_modal.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/tourisme_reservation_modale.dart';
import 'package:baobabe_0_2/features/order/presentation/bloc/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/mall_stores_page.dart';

class BusinessActionSection extends StatelessWidget {
  final Business business;

  const BusinessActionSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [];

    final bool canReserve = business.specificData['canReserve']?.toString() == "true";
    final bool hasDelivery = business.specificData['hasDelivery']?.toString() == "true";

    const String resIcon = "assets/icons/calendar-date-svgrepo-com (1).svg";

    // --- Réservation selon type ---
    if (business.type == BusinessType.restaurant && canReserve) {
      actions.add(_buildActionButton(
        context,
        icon: resIcon,
        label: "Réserver table",
        onTap: () => _showReservationModal(context, business, 'restaurant'),
      ));
    } else if (business.type == BusinessType.hotel) {
      actions.add(_buildActionButton(
        context,
        icon: resIcon,
        label: "Réserver chambre",
        onTap: () => _showHotelRoomsList(context, business), // ✅ Nouvelle navigation
      ));
    } else if (business.type == BusinessType.carRental || business.type == BusinessType.travelAgency) {
      actions.add(_buildActionButton(
        context,
        icon: resIcon,
        label: "Réserver véhicule",
        onTap: () => _showReservationModal(context, business, 'car_rental'),
      ));
    } else if (business.type == BusinessType.spa) {
      actions.add(_buildActionButton(
        context,
        icon: resIcon,
        label: "Réserver soin",
        onTap: () => _showReservationModal(context, business, 'spa'),
      ));
    } else if (business.type == BusinessType.tourism) {
      actions.add(_buildActionButton(
        context,
        icon: resIcon,
        label: "Réserver activité",
        onTap: () => _showReservationModal(context, business, 'tourism'),
      ));
    } else if (business.type == BusinessType.cinema) {
      actions.add(_buildMovieActionButton(context, business));
    }

    // --- Restauration ---
    final bool isFood = business.type == BusinessType.restaurant || business.type == BusinessType.fastFood;
    if (isFood && hasDelivery) {
      actions.add(_buildActionButton(
        context,
        icon: "assets/icons/delivery-svgrepo-com.svg",
        label: "Commander",
        onTap: () => _orderFood(context, business),
      ));
      actions.add(_buildActionButton(
        context,
        icon: "assets/icons/menu-food-svgrepo-com.svg",
        label: "Menu",
        onTap: () => _showMenu(context, business),
      ));
    }

    // --- Mall (centre commercial) ---
    if (business.type == BusinessType.mall) {
      actions.add(_buildActionButton(
        context,
        icon: "assets/icons/shop-svgrepo-com.svg",
        label: "Boutiques",
        onTap: () => _showMallStores(context, business),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Wrap(
          spacing: 15,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: actions,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String icon, required String label, required VoidCallback onTap}) {
    final Color categoryColor = AppColors.primary;
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconButton(
                icon: SvgPicture.asset(
                  icon,
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(categoryColor, BlendMode.srcIn),
                ),
                onPressed: onTap,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMovieActionButton(BuildContext context, Business business) {
    final Color categoryColor = AppColors.primary;
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.movie, size: 28),
                color: categoryColor,
                onPressed: () => _showCinemaMovies(context, business),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voir les films',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showReservationModal(BuildContext context, Business business, String type) {
    final bloc = context.read<BusinessDetailBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: bloc,
        child: _buildModalContent(type, business),
      ),
    );
  }

  Widget _buildModalContent(String type, Business business) {
    switch (type) {
      case 'restaurant':
        return RestaurantReservationSheet(business: business);
      case 'car_rental':
        return CarRentalSheet(business: business);
      case 'spa':
        return SpaSheet(business: business);
      case 'tourism':
        return TourismSheet(business: business);
      default:
        return Container();
    }
  }

  void _showCinemaMovies(BuildContext context, Business business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CinemaListScreen(cinema: business),
      ),
    );
  }

  // ✅ Navigation vers la liste des chambres
  void _showHotelRoomsList(BuildContext context, Business business) {
    final bloc = context.read<BusinessDetailBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelRoomsListPage(hotel: business, businessDetailBloc: bloc,),
      ),
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
      _showSnackBar(context, 'Aucune boutique disponible');
    }
  }

  // ✅ Menu (lecture API)
  void _showMenu(BuildContext context, Business business) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = Injector.get<BusinessRepository>();
      final items = await repository.getMenuByBusiness(business.id);
      if (items.isNotEmpty) {
        final bloc = context.read<BusinessDetailBloc>();
        Navigator.pop(context); // fermer loader
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (routeContext) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: bloc),
                BlocProvider(create: (_) => CartCubit()),
              ],
              child: RestaurantMenuPage(
                menuItems: items,
                restaurantId: business.id,
                restaurantName: business.name,
              ),
            ),
          ),
        );
      } else {
        Navigator.pop(context);
        _showSnackBar(context, 'Menu non disponible');
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar(context, 'Erreur de chargement du menu');
      debugPrint('Erreur menu: $e');
    }
  }

  // ✅ Commander (lecture API)
  void _orderFood(BuildContext context, Business business) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = Injector.get<BusinessRepository>();
      final items = await repository.getMenuByBusiness(business.id);
      if (items.isNotEmpty) {
        final bloc = context.read<BusinessDetailBloc>();
        final uiBusiness = UIBusiness(business);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (routeContext) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: bloc),
                BlocProvider(create: (_) => CartCubit()),
              ],
              child: MenuSection(
                menuItems: items,
                restaurantId: business.id,
                restaurantName: business.name,
                restaurantType: business.type,
                business: business,
                uiBusiness: uiBusiness,
              ),
            ),
          ),
        );
      } else {
        Navigator.pop(context);
        _showSnackBar(context, 'Menu non disponible pour la commande');
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar(context, 'Erreur de chargement du menu');
      debugPrint('Erreur commande: $e');
    }
  }

  List<MenuItem> _convertToMenuItemList(List<dynamic> data) {
    return data.map((item) {
      if (item is MenuItem) return item;
      return MenuItem(
        id: item['id'] as int? ?? 0,
        businessId: item['business_id']?.toString() ?? '',
        itemName: item['item_name'] as String? ?? 'Nom inconnu',
        itemCategory: item['item_category'] as String? ?? 'Général',
        price: (item['price'] as num?)?.toDouble() ?? 0.0,
        description: item['description'] as String? ?? '',
        imageUrl: item['image_url'] as String? ?? '',
        ingredients: item['ingredients'] != null ? List<String>.from(item['ingredients'] as List) : [],
      );
    }).toList();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }
}