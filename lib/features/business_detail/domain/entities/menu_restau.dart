import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String itemName;
  final double price;
  final String itemCategory;
  final String imageUrl;
  final double rating;
  final String description;
  final List<String> ingredients;

  const MenuItem({
    required this.itemName,
    required this.price,
    required this.itemCategory,
    required this.imageUrl,
    required this.rating,
    required this.description,
    required this.ingredients,
  });

  @override
  List<Object> get props => [
    itemName,
    price,
    itemCategory,
    imageUrl,
    rating,
    description,
    ingredients,
  ];
}