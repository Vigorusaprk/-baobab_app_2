import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/order/data/services/vehicle_service.dart';
import 'package:baobabe_0_2/features/order/data/models/vehicle_model.dart';
import 'car_vehicle_card.dart';

class CarListPage extends StatefulWidget {
  final String businessId;
  final String businessName;

  const CarListPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

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
        return CarVehicleCard(
          vehicle: vehicle,
          businessId: widget.businessId,
          businessName: widget.businessName,
        );
      },
    );
  }
}