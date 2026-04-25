import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/order/data/services/vehicle_service.dart';
import 'package:baobabe_0_2/features/order/data/models/vehicle_model.dart';
import 'car_detail_page.dart';

class CarListPage extends StatefulWidget {
  final String businessId;
  final String businessName;

  const CarListPage({
    required this.businessId,
    required this.businessName,
    Key? key,
  }) : super(key: key);

  @override
  State<CarListPage> createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = _fetchVehicles();
  }

  Future<List<Vehicle>> _fetchVehicles() async {
    try {
      final vehiclesData = await VehicleService.getVehicles(widget.businessId);
      return vehiclesData.map((v) => Vehicle.fromJson(v)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des véhicules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== APP BAR ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.scaffoldBackground),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Icon(Icons.directions_car, color: AppColors.primary, size: 35), // Remplace SVG
          const SizedBox(width: 12),
          Text(
            'Louez un véhicule ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.scaffoldBackground,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CONTENU PRINCIPAL ====================
  Widget _buildContent() {
    return FutureBuilder<List<Vehicle>>(
      future: _vehiclesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final vehicles = snapshot.data ?? [];

        if (vehicles.isEmpty) {
          return _buildEmptyState();
        }

        return _buildVehicleList(vehicles);
      },
    );
  }

  // ==================== ÉTAT VIDE ====================
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun véhicule disponible'),
        ],
      ),
    );
  }

  // ==================== ERREUR ====================
  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erreur: $errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _vehiclesFuture = _fetchVehicles();
              });
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // ==================== LISTE DES VÉHICULES ====================
  Widget _buildVehicleList(List<Vehicle> vehicles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  // ==================== CARTE D'UN VÉHICULE ====================
  Widget _buildVehicleCard(Vehicle vehicle) {
    final bool isAvailable = vehicle.availableQuantity > 0;

    return GestureDetector(
      onTap: isAvailable
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailPage(
              businessId: widget.businessId,
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
            // Image
            _buildVehicleImage(vehicle),
            // Détails
            _buildVehicleDetails(vehicle, isAvailable),
          ],
        ),
      ),
    );
  }

  // ==================== IMAGE DU VÉHICULE ====================
  Widget _buildVehicleImage(Vehicle vehicle) {
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

  // ==================== DÉTAILS DU VÉHICULE ====================
  Widget _buildVehicleDetails(Vehicle vehicle, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En‑tête : nom, type et prix
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
                        color: Colors.black87,   // ← personnalisable
                      ),
                    ),
                    Text(
                      vehicle.type,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600], // ← personnalisable
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
          // Caractéristiques
          if (vehicle.features.isNotEmpty) _buildFeatures(vehicle.features),
          const SizedBox(height: 12),
          // Disponibilité
          _buildAvailability(isAvailable, vehicle.availableQuantity),
        ],
      ),
    );
  }

  // ==================== CARACTÉRISTIQUES ====================
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

  // ==================== DISPONIBILITÉ ====================
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