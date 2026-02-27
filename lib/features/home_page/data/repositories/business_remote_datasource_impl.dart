// lib/features/business/data/datasources/business_remote_datasource_impl.dart
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:dio/dio.dart';

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final Dio _dio;
  final String _baseUrl;

  BusinessRemoteDataSourceImpl({Dio? dio, String baseUrl = 'https://api.example.com'})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl;

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    try {
      final response = await _dio.get('$_baseUrl/businesses');
      return (response.data as List)
          .map((json) => BusinessModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load businesses: $e');
    }
  }

  @override
  Future<BusinessModel> getBusinessDetail(String businessId) async {
    try {
      final response = await _dio.get('$_baseUrl/businesses/$businessId');
      return BusinessModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load business details: $e');
    }
  }

  @override
  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/businesses',
        queryParameters: {'category': category},
      );
      return (response.data as List)
          .map((json) => BusinessModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load businesses by category: $e');
    }
  }
}