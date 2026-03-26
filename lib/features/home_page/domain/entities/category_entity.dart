import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String displayName;

  const Category({
    required this.id,
    required this.name,
    required this.displayName,
  });

  static final allCategories = [
    Category(id: '0', name: 'all', displayName: 'Tout'),
    Category(id: '1', name: 'restaurant', displayName: 'Restaurants'),
    Category(id: '2', name: 'fastFood', displayName: 'Fast Food'),
    Category(id: '3', name: 'shopping', displayName: 'Shopping'),
    Category(id: '4', name: 'mall', displayName: 'Centres Commerciaux'),
    Category(id: '5', name: 'hotel', displayName: 'Hôtels'),
    Category(id: '6', name: 'carRental', displayName: 'Location Voiture'),
    Category(id: '7', name: 'travelAgency', displayName: 'Voyage'),
    Category(id: '8', name: 'spa', displayName: 'Spa'),
    Category(id: '9', name: 'cinema', displayName: 'Cinema'),
    Category(id: '10', name: 'tourisme', displayName: 'Tourisme')

  ];

  static Category fromBusinessType(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return allCategories[1];
      case BusinessType.fastFood:
        return allCategories[2];
      case BusinessType.shopping:
        return allCategories[3];
      case BusinessType.mall:
        return allCategories[4];
      case BusinessType.hotel:
        return allCategories[5];
      case BusinessType.carRental:
        return allCategories[6];
      case BusinessType.travelAgency:
        return allCategories[7];
      case BusinessType.spa:
        return allCategories[8];
      case BusinessType.cinema:
        return allCategories[9];
      case BusinessType.tourisme:
        return allCategories[10];
      default:
        return allCategories[0];
    }
  }

  @override
  List<Object> get props => [id, name, displayName];
}