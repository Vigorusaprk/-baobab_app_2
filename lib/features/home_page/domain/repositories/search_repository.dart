import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';

abstract class SearchRepository {
  Future<List<Business>> searchBusinesses(SearchFilterEntity filters);
  Future<List<BusinessType>> getAvailableCategories();
  Future<List<String>> getAvailableLocations();
}
