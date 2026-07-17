import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/order/data/models/vehicle_model.dart';
import 'car_detail_page.dart';

class CarVehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final String businessId;
  final String businessName;

  const CarVehicleCard({
    super.key,
    required this.vehicle,
    required this.businessId,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = vehicle.availableQuantity > 0;

    return GestureDetector(
      onTap: isAvailable
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailPage(
              businessId: businessId,
              businessName: businessName,
              vehicle: vehicle,
            ),
          ),
        );
      }
          : null,
      child: Card(
        color: AppColors.scaffoldBackground,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleImage(),
            _buildVehicleDetails(isAvailable),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: vehicle.imageUrl.isNotEmpty
          ? ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Image.network(
          vehicle.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(Icons.directions_car, size: 80, color: Colors.grey[600]),
          ),
        ),
      )
          : Center(
        child: Icon(Icons.directions_car, size: 80, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildVehicleDetails(bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      vehicle.type,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isAvailable ? AppColors.primaryLight : Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${vehicle.dailyPrice.toStringAsFixed(0)}€/jour',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (vehicle.features.isNotEmpty) _buildFeatures(vehicle.features),
          const SizedBox(height: 12),
          _buildAvailability(isAvailable, vehicle.availableQuantity),
        ],
      ),
    );
  }

  Widget _buildFeatures(List<String> features) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((feature) {
        return Chip(
          label: Text(
            feature,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          backgroundColor: Colors.grey[200],
          padding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildAvailability(bool isAvailable, int quantity) {
    return Text(
      isAvailable
          ? '✅ $quantity disponible(s)'
          : '❌ Indisponible',
      style: TextStyle(
        fontSize: 12,
        color: isAvailable ? Colors.green : Colors.red,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
