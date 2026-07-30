import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/room.dart';

class RoomApiService {
  final SupabaseClient _supabase;

  RoomApiService([SupabaseClient? supabase])
    : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Room>> getRoomsByHotel(String businessId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('business_id', businessId);

      return (response as List<dynamic>)
          .map((json) => Room.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des chambres : $e');
    }
  }
}
