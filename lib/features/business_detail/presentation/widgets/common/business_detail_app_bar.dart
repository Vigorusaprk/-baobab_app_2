import 'dart:ui';

import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_hero_section.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class BusinessDetailAppBar extends StatelessWidget {
  final Business business;
  final UIBusiness uiBusiness;
  final ScrollController scrollController;

  const BusinessDetailAppBar({
    super.key,
    required this.uiBusiness,
    required this.business,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.scaffoldBackground,
      expandedHeight: 350,
      pinned: true,
      elevation: 0,
      leading: Row(
        children: [
          const SizedBox(width: 7),
          _buildCircleButton(
            context,
            Icons.arrow_back_ios_new_rounded,
                () => Navigator.pop(context),
          ),
        ],
      ),
      actions: [
        _buildCircleButton(
          context,
          business.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              () {},
          iconColor: business.isFavorite ? Colors.red : Colors.white,
        ),
        const SizedBox(width: 7),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double topPadding = MediaQuery.of(context).padding.top;
          final double collapsedHeight = kToolbarHeight + topPadding;

          // Détermine si la barre est pliée
          final bool isCollapsed = constraints.biggest.height <= collapsedHeight + 20;

          return FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            centerTitle: true,
            background: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Image de fond (S'efface doucement quand plié)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isCollapsed ? 0.0 : 1.0,
                  child: Hero(
                    tag: 'business-image-${business.id}',
                    child: _buildBackgroundImage(),
                  ),
                ),

                // 2. Le fond dégradé opaque (Apparaît quand plié)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isCollapsed ? 1.0 : 0.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,       // Couleur unie sans transparence
                          AppColors.primaryLight,  // Couleur unie sans transparence
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Infos du business (Positioned est BIEN placé comme enfant direct du Stack)
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isCollapsed ? 0.0 : 1.0,
                    child: BusinessHeroSection(uiBusiness: uiBusiness, business: business,),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context, IconData icon, VoidCallback onTap, {Color iconColor = Colors.white}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(

          color: uiBusiness.categoryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: IconButton(
            icon: Icon(icon, color: iconColor, size: 20),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    final hasImage = business.bgImg != null && business.bgImg!.isNotEmpty;
    final Color color = uiBusiness.categoryColor;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: hasImage ? null : uiBusiness.categoryColor,
      ),
      child: hasImage
          ? ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.network(
          business.bgImg!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsContainer(color),
        ),
      )
          : _buildInitialsContainer(color),
    );
  }

  Widget _buildInitialsContainer(Color color) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(28)),
      width: double.infinity,
      height: 200,
    );
  }
}