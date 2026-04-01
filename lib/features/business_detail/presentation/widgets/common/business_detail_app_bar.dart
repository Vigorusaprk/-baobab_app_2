import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class BusinessDetailAppBar extends StatelessWidget {
  final Business business;
  final UIBusiness uiBusiness;

  const BusinessDetailAppBar({super.key, required this.uiBusiness,required this.business});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF254D32),
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      leading: _buildCircleButton(
          context,
          Icons.arrow_back_ios_new_rounded,
              () => Navigator.pop(context)
      ),
      actions: [
        _buildCircleButton(
          context,
          business.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              () {},
          iconColor: business.isFavorite ? Colors.red : Colors.white,
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        centerTitle: true,
        title: Text(
          business.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'business-image-${business.id}',
              child: _buildBackGroudImage(),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      BuildContext context,
      IconData icon,
      VoidCallback onTap,
      {Color iconColor = Colors.white}
      ) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onTap,
      ),
    );
  }

// Widget pour l'image de profil (grande zone)
  Widget _buildBackGroudImage(){
    final hasImage = business.bgImg != null && business.bgImg!.isNotEmpty;
    final Color = uiBusiness.categoryColor;

    return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: hasImage ? null : uiBusiness.categoryColor, // Fond coloré si pas d'image
        ),
        child: hasImage ?
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.network(
            uiBusiness.business.bgImg!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Si l'image ne se charge pas, afficher les initiales
              return _buildInitialsContainer(Color);
            },
          ),
        ) : _buildInitialsContainer(Color)
    );
  }

  Widget _buildInitialsContainer(Color color) {
    return Container(
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28)
      ),
      width: double.infinity,
      height: 200,
      child: Center(
          child: Icon(
            uiBusiness.categoryIcon,
            size: 80,
            color: Colors.white,
          )
      ),
    );
  }


}