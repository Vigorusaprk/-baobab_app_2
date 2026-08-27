import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/car_list_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/hotel_rooms_list_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/restaurant_menu_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/menu_section.dart';
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

BusinessRepository _createBusinessRepository() =>
    BusinessRepositoryImpl(remoteDataSource: BusinessRemoteDataSourceImpl());

/// Parcours **spécialisés** déclenchés depuis [BusinessActionSection].
///
/// Ne restent ici que ceux qui apportent des étapes que le catalogue
/// générique ne couvre pas : la mise en avant d'un menu, et le choix d'une
/// plage de dates pour une chambre ou un véhicule.
///
/// Les tunnels par métier (cinéma, centre commercial, spa, tourisme,
/// voyage, réservation de table) ont été retirés : ils interrogeaient des
/// tables inexistantes ou des champs jamais renseignés, et menaient donc
/// systématiquement à une page vide. Ces catégories passent désormais par
/// `OfferCataloguePage`, qui les rend réellement fonctionnelles.
class BusinessActionNavigator {
  const BusinessActionNavigator._();

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
        _showSnackBar(context, 'Aucun menu disponible pour le moment');
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showSnackBar(context, 'Impossible de charger le menu');
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
        _showSnackBar(context, 'Rien à commander pour le moment');
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showSnackBar(context, 'Impossible de charger la carte');
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.warning),
    );
  }
}
