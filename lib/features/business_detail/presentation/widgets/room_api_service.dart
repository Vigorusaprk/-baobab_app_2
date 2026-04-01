import 'package:baobabe_0_2/features/business_detail/data/models/room.dart';
import 'package:dio/dio.dart';

class RoomApiService {
  final Dio _dio;
  final String _baseUrl;

  RoomApiService({Dio? dio, String baseUrl = 'http://10.0.2.2:3000/api'})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl;

  Future<List<Room>> getRoomsByHotel(String businessId) async {
    try {
      final response = await _dio.get('$_baseUrl/businesses/$businessId/rooms');
      final List data = response.data;
      return data.map((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des chambres : $e');
    }
  }
}