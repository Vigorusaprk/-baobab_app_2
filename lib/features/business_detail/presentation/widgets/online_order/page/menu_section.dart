import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/menu_tab_content.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/menu_top_bar.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/order/presentation/bloc/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        length: categories
            .length, // OBLIGATOIRE pour synchroniser la TabBar et le TabBarView
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              MenuTopBar(
                restaurantId: restaurantId,
                restaurantName: restaurantName,
                restaurantType: restaurantType,
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
                  child: MenuTabContent(
                    menuItems: menuItems,
                    categories: categories,
                    groupedItems: groupedItems,
                    restaurantId: restaurantId,
                    restaurantName: restaurantName,
                    restaurantType: restaurantType,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
