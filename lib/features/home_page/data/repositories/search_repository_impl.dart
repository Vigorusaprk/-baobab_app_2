import 'package:baobabe_0_2/core/errors/exeptions.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/search_repository.dart';

import '../data_sources/remote_datasource/business_remote_datasource.dart'
    show BusinessRemoteDataSource;

class SearchRepositoryImpl implements SearchRepository {
  final BusinessRemoteDataSource localDataSource;

  SearchRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Business>> searchBusinesses(SearchFilterEntity filters) async {
    try {
      final allBusinesses = await localDataSource.getBusinesses();
      final businesses = allBusinesses
          .map((model) => model.toEntity())
          .toList();

      var results = businesses.where((business) {
        // Filtre par texte
        if (filters.query.isNotEmpty) {
          final query = filters.query.toLowerCase();
          final nameMatch = business.name.toLowerCase().contains(query);
          final descMatch = business.description.toLowerCase().contains(query);
          final addressMatch = business.address.toLowerCase().contains(query);
          if (!nameMatch && !descMatch && !addressMatch) return false;
        }

        // Filtre par catégorie
        if (filters.category != null && business.type != filters.category) {
          return false;
        }

        // Filtre par note minimale
        if (filters.minRating != null && business.rating < filters.minRating!) {
          return false;
        }

        // Filtre par localisation (adresse)
        if (filters.location != null && filters.location!.isNotEmpty) {
          if (!business.address.toLowerCase().contains(
            filters.location!.toLowerCase(),
          )) {
            return false;
          }
        }

        return true;
      }).toList();

      // Tri
      results = _sortResults(results, filters.sortBy);

      return results;
    } catch (e) {
      // On relance l'exception pour que le bloc la capture
      throw CacheExeption(message: e.toString());
    }
  }

  @override
  Future<List<BusinessType>> getAvailableCategories() async {
    try {
      final businesses = await localDataSource.getBusinesses();
      final types = businesses.map((b) => b.type).toSet().toList();
      return types;
    } catch (e) {
      throw CacheExeption(message: e.toString());
    }
  }

  @override
  Future<List<String>> getAvailableLocations() async {
    try {
      final businesses = await localDataSource.getBusinesses();
      final locations = businesses.map((b) => b.address).toSet().toList();
      return locations;
    } catch (e) {
      throw CacheExeption(message: e.toString());
    }
  }

  List<Business> _sortResults(List<Business> results, SortBy sortBy) {
    switch (sortBy) {
      case SortBy.ratingDesc:
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortBy.ratingAsc:
        results.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case SortBy.priceDesc:
        results.sort((a, b) => _extractPrice(b).compareTo(_extractPrice(a)));
        break;
      case SortBy.priceAsc:
        results.sort((a, b) => _extractPrice(a).compareTo(_extractPrice(b)));
        break;
      case SortBy.newest:
        // Pas de date de création, on garde l'ordre par défaut
        break;
      case SortBy.relevance:
        // Ordre par défaut
        break;
    }
    return results;
  }

  double _extractPrice(Business business) {
    // Extraction d'un prix moyen selon le type (similaire à avant)
    if (business.type == BusinessType.hotel &&
        business.specificData['roomTypes'] != null) {
      final roomTypes = business.specificData['roomTypes'] as List;
      if (roomTypes.isNotEmpty) {
        double total = 0;
        for (var room in roomTypes) {
          total += (room['price'] as num?)?.toDouble() ?? 0;
        }
        return total / roomTypes.length;
      }
    } else if (business.type == BusinessType.carRental &&
        business.specificData['vehicleTypes'] != null) {
      final vehicles = business.specificData['vehicleTypes'] as List;
      if (vehicles.isNotEmpty) {
        double total = 0;
        for (var v in vehicles) {
          total += (v['dailyPrice'] as num?)?.toDouble() ?? 0;
        }
        return total / vehicles.length;
      }
    } else if (business.type == BusinessType.travelAgency &&
        business.specificData['destinations'] != null) {
      final destinations = business.specificData['destinations'] as List;
      if (destinations.isNotEmpty) {
        double total = 0;
        for (var d in destinations) {
          total += (d['price'] as num?)?.toDouble() ?? 0;
        }
        return total / destinations.length;
      }
    }
    return 0;
  }
}
