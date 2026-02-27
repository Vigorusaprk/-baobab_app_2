import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class BusinessDetailAppBar extends StatelessWidget {
  final Business business;

  const BusinessDetailAppBar({super.key, required this.business});

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
              child: Image.asset(business.bgImg, fit: BoxFit.cover),
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
}