import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_action_button.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_action_navigator.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

class BusinessActionSection extends StatelessWidget {
  final Business business;

  const BusinessActionSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [];

    final bool canReserve = business.specificData['canReserve']?.toString() == "true";
    final bool hasDelivery = business.specificData['hasDelivery']?.toString() == "true";

    const String resIcon = "assets/icons/calendar-date-svgrepo-com (1).svg";

    if (business.type == BusinessType.restaurant && canReserve) {
      actions.add(BusinessActionButton(
        icon: resIcon,
        label: "Réserver table",
        onTap: () => BusinessActionNavigator.showReservationModal(context, business, 'restaurant'),
      ));
    } else if (business.type == BusinessType.hotel) {
      actions.add(BusinessActionButton(
        icon: resIcon,
        label: "Réserver chambre",
        onTap: () => BusinessActionNavigator.showHotelRoomsList(context, business),
      ));
    } else if (business.type == BusinessType.carRental) {
      actions.add(BusinessActionButton(
        icon: resIcon,
        label: "Réserver véhicule",
        onTap: () => BusinessActionNavigator.showCarRentalList(context, business),
      ));
    } else if (business.type == BusinessType.travelAgency) {
      actions.add(BusinessActionButton(
        icon: resIcon,
        label: "Réserver voyage",
        onTap: () => BusinessActionNavigator.showReservationModal(context, business, 'travel'),
      ));
    } else if (business.type == BusinessType.spa) {
      actions.add(BusinessActionButton(
        icon: resIcon,
        label: "Réserver soin",
        onTap: () => BusinessActionNavigator.showReservationModal(context, business, 'spa'),
      ));
    } else if (business.type == BusinessType.tourism) {
      actions.add(BusinessActionButton(
        icon: resIcon,
        label: "Réserver activité",
        onTap: () => BusinessActionNavigator.showReservationModal(context, business, 'tourism'),
      ));
    } else if (business.type == BusinessType.cinema) {
      actions.add(BusinessMovieActionButton(
        onTap: () => BusinessActionNavigator.showCinemaMovies(context, business),
      ));
    }

    final bool isFood = business.type == BusinessType.restaurant || business.type == BusinessType.fastFood;
    if (isFood && hasDelivery) {
      actions.add(BusinessActionButton(
        icon: "assets/icons/delivery-svgrepo-com.svg",
        label: "Commander",
        onTap: () => BusinessActionNavigator.orderFood(context, business),
      ));
      actions.add(BusinessActionButton(
        icon: "assets/icons/menu-food-svgrepo-com.svg",
        label: "Menu",
        onTap: () => BusinessActionNavigator.showMenu(context, business),
      ));
    }

    if (business.type == BusinessType.mall) {
      actions.add(BusinessActionButton(
        icon: "assets/icons/shop-svgrepo-com.svg",
        label: "Boutiques",
        onTap: () => BusinessActionNavigator.showMallStores(context, business),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Wrap(
            spacing: 15,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: actions,
          ),
        ),
      ),
    );
  }
}
