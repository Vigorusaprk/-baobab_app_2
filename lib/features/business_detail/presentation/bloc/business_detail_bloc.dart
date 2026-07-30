import 'dart:convert';

import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/get_business_detail.dart';

part 'business_detail_event.dart';
part 'business_detail_state.dart';

class BusinessDetailBloc
    extends Bloc<BusinessDetailEvent, BusinessDetailState> {
  final GetBusinessDetail getBusinessDetail;
  final BusinessRepository repository;
  final String businessId;

  BusinessDetailBloc({
    required this.getBusinessDetail,
    required this.repository,
    required this.businessId,
  }) : super(const BusinessDetailState()) {
    on<LoadBusinessDetail>(_onLoadBusinessDetail);
    on<MakeReservation>(_onMakeReservation);
    on<AddToCart>(_onAddToCart); // Nouvelle action
    on<LoadCart>(_onLoadCart); // Nouvelle action
  }

  Future<void> _onLoadBusinessDetail(
    LoadBusinessDetail event,
    Emitter<BusinessDetailState> emit,
  ) async {
    emit(state.copyWith(detailStatus: BusinessDetailStatus.loading));
    try {
      final business = await getBusinessDetail(event.businessId);
      emit(
        state.copyWith(
          detailStatus: BusinessDetailStatus.loaded,
          business: business,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          detailStatus: BusinessDetailStatus.error,
          detailErrorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMakeReservation(
    MakeReservation event,
    Emitter<BusinessDetailState> emit,
  ) async {
    // On passe le statut en loading sans perdre l'objet 'business' actuel
    emit(state.copyWith(reservationStatus: ReservationStatus.loading));
    try {
      await repository.createReservation(event.reservation);
      emit(state.copyWith(reservationStatus: ReservationStatus.success));

      // Optionnel : Recharger discrètement les données du business si nécessaire
      final updatedBusiness = await getBusinessDetail(businessId);
      emit(
        state.copyWith(
          detailStatus: BusinessDetailStatus.loaded,
          business: updatedBusiness,
          reservationStatus:
              ReservationStatus.initial, // Reset le statut après succès
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          reservationStatus: ReservationStatus.error,
          reservationErrorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<BusinessDetailState> emit,
  ) async {
    // 1. On récupère la liste actuelle
    final List<OrderItem> updatedList = List<OrderItem>.from(state.cartItems);

    // 2. Vérification : existe-t-il déjà un article avec cet ID ?
    final int index = updatedList.indexWhere(
      (item) => item.menuItemId == event.item.menuItemId,
    );

    if (index != -1) {
      // 3. S'il existe, on met à jour la quantité de l'objet existant
      final existingItem = updatedList[index];
      updatedList[index] = existingItem.copyWith(
        quantity: existingItem.quantity + event.item.quantity,
      );
    } else {
      // 4. Sinon, on ajoute le nouvel article
      updatedList.add(event.item);
    }

    // 5. On émet le nouvel état
    emit(state.copyWith(cartItems: updatedList));

    // 6. Sauvegarde (persistance)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_cart',
      jsonEncode(updatedList.map((i) => i.toMap()).toList()),
    );
  }

  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<BusinessDetailState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('saved_cart');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      final items = decoded.map((i) => OrderItem.fromMap(i)).toList();
      emit(state.copyWith(cartItems: items));
    }
  }
}
