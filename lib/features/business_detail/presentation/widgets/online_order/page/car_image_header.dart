import 'package:flutter/material.dart';

/// Image du véhicule et bandeau d'avertissement si l'utilisateur n'est pas
/// connecté.
class CarImageHeader extends StatelessWidget {
  final String imageUrl;
  final bool isLoggedIn;

  const CarImageHeader({
    super.key,
    required this.imageUrl,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
        ),
        if (!isLoggedIn)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade100,
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Veuillez vous connecter pour réserver',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
