import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

/// One page of the business feed, used to drive infinite scroll: the UI
/// only needs to know "here are more items" and "is there another page",
/// nothing about how pagination is implemented server-side.
class BusinessesPage {
  final List<Business> items;
  final bool hasMore;

  const BusinessesPage({required this.items, required this.hasMore});
}
