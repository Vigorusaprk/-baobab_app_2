import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/car_list_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/cinema_list_screen.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/hotel_rooms_list_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/reservation_modal.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/restaurant_menu_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/menu_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/spa_reservation_modal.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/tourisme_reservation_modale.dart';
import 'package:baobabe_0_2/features/order/presentation/bloc/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/mall_stores_page.dart';

BusinessRepository _createBusinessRepository() =>
    BusinessRepositoryImpl(remoteDataSource: BusinessRemoteDataSourceImpl());

/// Regroupe les actions de navigation / modales déclenchées depuis
/// [BusinessActionSection] (réservations, menu, commande, boutiques, ...).
/// Extrait de business_actions_section.dart afin de garder ce dernier
/// concis ; comportement strictement identique.
class BusinessActionNavigator {
  const BusinessActionNavigator._();

  static void showReservationModal(
    BuildContext context,
    Business business,
    String type,
  ) {
    final bloc = context.read<BusinessDetailBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: bloc,
        child: _buildModalContent(type, business),
      ),
    );
  }

  static Widget _buildModalContent(String type, Business business) {
    switch (type) {
      case 'restaurant':
        return ReservationModal(business: business);
      case 'spa':
        return SpaReservationModal(business: business);
      case 'tourism':
        return TourismReservationModal(business: business);
      default:
        return Container();
    }
  }

  static void showCinemaMovies(BuildContext context, Business business) {
    final bloc = context.read<BusinessDetailBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CinemaListScreen(cinema: business, businessDetailBloc: bloc),
      ),
    );
  }

  static void showHotelRoomsList(BuildContext context, Business business) {
    final bloc = context.read<BusinessDetailBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HotelRoomsListPage(hotel: business, businessDetailBloc: bloc),
      ),
    );
  }

  static void showCarRentalList(BuildContext context, Business business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CarListPage(businessId: business.id, businessName: business.name),
      ),
    );
  }

  static void showMallStores(BuildContext context, Business business) {
    if (business.stores != null && business.stores!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MallStoresPage(stores: business.stores!, mallName: business.name),
        ),
      );
    } else {
      _showSnackBar(context, 'Aucune boutique disponible');
    }
  }

  static void showMenu(BuildContext context, Business business) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = _createBusinessRepository();
      final items = await repository.getMenuByBusiness(business.id);
      if (!context.mounted) return;
      if (items.isNotEmpty) {
        final bloc = context.read<BusinessDetailBloc>();
        Navigator.pop(context);
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
      if (context.mounted) Navigator.pop(context);
      _showSnackBar(context, 'Erreur de chargement du menu');
    }
  }

  static void orderFood(BuildContext context, Business business) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = _createBusinessRepository();
      final items = await repository.getMenuByBusiness(business.id);
      if (!context.mounted) return;
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
      debugPrint("ERREUR DE CHARGEMENT : $e"); // AJOUTEZ CECI
      if (context.mounted) Navigator.pop(context);
      _showSnackBar(context, 'Erreur de chargement: $e');
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }
}
