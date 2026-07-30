import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/room.dart';
import 'package:flutter/material.dart';

/// Image principale de la chambre (sans padding, occupe toute la largeur).
class RoomImageHeader extends StatelessWidget {
  final Room room;

  const RoomImageHeader({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        image: room.images != null && room.images!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(room.images!.first),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: room.images == null || room.images!.isEmpty
          ? const Icon(Icons.hotel, size: 80, color: AppColors.textSecondary)
          : null,
    );
  }
}

/// Informations textuelles de la chambre (nom, prix, capacité, description,
/// équipements). Ne contient pas de padding : le parent applique le padding
/// commun à toute la section de contenu.
class RoomInfoHeader extends StatelessWidget {
  final Room room;

  const RoomInfoHeader({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          room.roomType,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${room.pricePerNight.toStringAsFixed(2)} € / nuit',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text('Capacité: ${room.capacity} personnes'),
        const SizedBox(height: 4),
        Text('Disponibles: ${room.availableQuantity} chambres'),
        if (room.description != null) ...[
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(room.description!),
        ],
        if (room.amenities != null && room.amenities!.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Équipements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: room.amenities!.entries.map((entry) {
              if (entry.value == true) {
                return Chip(
                  label: Text(entry.key),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                );
              }
              return const SizedBox();
            }).toList(),
          ),
        ],
      ],
    );
  }
}
