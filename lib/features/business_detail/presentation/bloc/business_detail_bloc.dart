import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_business_detail.dart';

part 'business_detail_event.dart';
part 'business_detail_state.dart';

class BusinessDetailBloc extends Bloc<BusinessDetailEvent, BusinessDetailState> {
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
  }

  Future<void> _onLoadBusinessDetail(LoadBusinessDetail event, Emitter<BusinessDetailState> emit) async {
    emit(state.copyWith(detailStatus: BusinessDetailStatus.loading));
    try {
      final business = await getBusinessDetail(event.businessId);
      emit(state.copyWith(
        detailStatus: BusinessDetailStatus.loaded,
        business: business,
      ));
    } catch (e) {
      emit(state.copyWith(
        detailStatus: BusinessDetailStatus.error,
        detailErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMakeReservation(MakeReservation event, Emitter<BusinessDetailState> emit) async {
    // On passe le statut en loading sans perdre l'objet 'business' actuel
    emit(state.copyWith(reservationStatus: ReservationStatus.loading));
    try {
      await repository.createReservation(event.reservation);
      emit(state.copyWith(reservationStatus: ReservationStatus.success));

      // Optionnel : Recharger discrètement les données du business si nécessaire
      final updatedBusiness = await getBusinessDetail(businessId);
      emit(state.copyWith(
        detailStatus: BusinessDetailStatus.loaded,
        business: updatedBusiness,
        reservationStatus: ReservationStatus.initial, // Reset le statut après succès
      ));
    } catch (e) {
      emit(state.copyWith(
        reservationStatus: ReservationStatus.error,
        reservationErrorMessage: e.toString(),
      ));
    }
  }
}