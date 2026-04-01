import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final BusinessType type; // On change 'name' par 'type'
  final String displayName;

  const Category({
    required this.id,
    required this.type,
    required this.displayName,
  });

  static const allCategories = [
    Category(id: '0', type: BusinessType.other, displayName: 'Tout'),
    Category(id: '1', type: BusinessType.restaurant, displayName: 'Restaurants'),
    Category(id: '2', type: BusinessType.fastFood, displayName: 'Fast Food'),
    Category(id: '3', type: BusinessType.shopping, displayName: 'Shopping'),
    Category(id: '4', type: BusinessType.mall, displayName: 'Centres Commerciaux'),
    Category(id: '5', type: BusinessType.hotel, displayName: 'Hôtels'),
    Category(id: '6', type: BusinessType.carRental, displayName: 'Location Voiture'),
    Category(id: '7', type: BusinessType.travelAgency, displayName: 'Voyage'),
    Category(id: '8', type: BusinessType.spa, displayName: 'Spa'),
    Category(id: '9', type: BusinessType.cinema, displayName: 'Cinema'),
    Category(id: '10', type: BusinessType.tourism, displayName: 'Tourisme'),
  ];

  @override
  List<Object?> get props => [id, type, displayName];
}