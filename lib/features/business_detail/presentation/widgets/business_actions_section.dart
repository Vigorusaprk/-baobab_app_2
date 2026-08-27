import 'package:baobabe_0_2/features/business_detail/data/offer_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/screens/offer_catalogue_page.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_action_button.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_action_navigator.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Ce que l'utilisateur peut faire chez ce commerçant.
///
/// Les actions ne sont plus décidées par un `switch` sur le type de
/// commerce — qui laissait sans aucun bouton toute catégorie non prévue, et
/// affichait des boutons menant à des impasses pour celles dont le
/// catalogue n'existait pas. Elles découlent maintenant des offres
/// réellement publiées : **commander** s'il existe des offres à commander,
/// **réserver** s'il en existe à réserver, et rien du tout sinon.
///
/// Les parcours spécialisés déjà en place (menu d'un restaurant, chambres
/// d'un hôtel, flotte d'un loueur) sont conservés : ils apportent des
/// étapes que le parcours générique ne couvre pas, comme le choix d'une
/// plage de dates.
class BusinessActionSection extends StatefulWidget {
  final Business business;

  const BusinessActionSection({super.key, required this.business});

  @override
  State<BusinessActionSection> createState() => _BusinessActionSectionState();
}

class _BusinessActionSectionState extends State<BusinessActionSection> {
  static const String _reserveIcon =
      "assets/icons/calendar-date-svgrepo-com (1).svg";
  static const String _orderIcon = "assets/icons/delivery-svgrepo-com.svg";
  static const String _menuIcon = "assets/icons/menu-food-svgrepo-com.svg";

  BusinessCapabilities? _capabilities;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final catalogue = await OfferApiService().getCatalogue(widget.business.id);
    if (!mounted) return;
    setState(() {
      _capabilities = catalogue.capabilities;
      _loading = false;
    });
  }

  bool get _isFood =>
      widget.business.type == BusinessType.restaurant ||
      widget.business.type == BusinessType.fastFood;

  void _openCatalogue(Fulfilment fulfilment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfferCataloguePage(
          business: widget.business,
          fulfilment: fulfilment,
        ),
      ),
    );
  }

  /// Parcours de commande : le menu d'un restaurant offre une mise en avant
  /// des plats que la liste générique n'a pas, on le conserve.
  void _order() {
    if (_isFood) {
      BusinessActionNavigator.orderFood(context, widget.business);
      return;
    }
    _openCatalogue(Fulfilment.order);
  }

  /// Parcours de réservation : hôtel et location de véhicule demandent une
  /// plage de dates, que leurs écrans dédiés savent déjà collecter.
  void _book() {
    switch (widget.business.type) {
      case BusinessType.hotel:
        BusinessActionNavigator.showHotelRoomsList(context, widget.business);
      case BusinessType.carRental:
        BusinessActionNavigator.showCarRentalList(context, widget.business);
      default:
        _openCatalogue(Fulfilment.booking);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _ActionsSkeleton();

    final capabilities = _capabilities;
    // Aucune offre publiée : on n'affiche aucun bouton plutôt qu'un bouton
    // qui déboucherait sur une page vide.
    if (capabilities == null || !capabilities.hasAny) {
      return const SizedBox.shrink();
    }

    final actions = <Widget>[
      if (capabilities.canOrder)
        BusinessActionButton(
          icon: _orderIcon,
          label: 'Commander',
          onTap: _order,
        ),
      if (capabilities.canOrder && _isFood)
        BusinessActionButton(
          icon: _menuIcon,
          label: 'Voir le menu',
          onTap: () => BusinessActionNavigator.showMenu(context, widget.business),
        ),
      if (capabilities.canBook)
        BusinessActionButton(
          icon: _reserveIcon,
          label: 'Réserver',
          onTap: _book,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
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

class _ActionsSkeleton extends StatelessWidget {
  const _ActionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Skeletonizer(
          enabled: true,
          child: Wrap(
            spacing: 15,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Bone.circle(size: 56),
                  SizedBox(height: AppDimens.small),
                  Bone(width: 60, height: 10, uniRadius: 4),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Bone.circle(size: 56),
                  SizedBox(height: AppDimens.small),
                  Bone(width: 60, height: 10, uniRadius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
