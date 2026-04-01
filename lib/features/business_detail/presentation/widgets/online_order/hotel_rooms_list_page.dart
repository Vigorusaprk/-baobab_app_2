import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/data/models/room.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/room_api_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'room_detail_page.dart';

class HotelRoomsListPage extends StatefulWidget {
  final Business hotel;
  final BusinessDetailBloc businessDetailBloc;

  const HotelRoomsListPage({
    super.key,
    required this.hotel,
    required this.businessDetailBloc,
  });

  @override
  State<HotelRoomsListPage> createState() => _HotelRoomsListPageState();
}

class _HotelRoomsListPageState extends State<HotelRoomsListPage> {
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      final service = RoomApiService();
      final rooms = await service.getRoomsByHotel(widget.hotel.id);
      setState(() => _rooms = rooms);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chambres - ${widget.hotel.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
          ? const Center(child: Text('Aucune chambre disponible'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(room.roomType),
              subtitle: Text('${room.pricePerNight} €/nuit • ${room.capacity} pers.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: widget.businessDetailBloc,
                      child: RoomDetailPage(
                        hotel: widget.hotel,
                        room: room,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}