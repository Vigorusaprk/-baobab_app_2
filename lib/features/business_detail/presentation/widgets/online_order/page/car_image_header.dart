import 'package:flutter/material.dart';

/// Image du véhicule. La connexion n'est demandée qu'au moment de réserver,
/// pas à la simple consultation de la fiche.
class CarImageHeader extends StatelessWidget {
  final String imageUrl;

  const CarImageHeader({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[300],
      child: imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.directions_car,
            size: 100,
            color: Colors.grey[600],
          ),
        ),
      )
          : Center(
        child: Icon(
          Icons.directions_car,
          size: 100,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
