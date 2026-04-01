import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_business_detail.dart';
import '../../data/models/reservation_model.dart'; // ✅ import

part 'business_detail_event.dart';
part 'business_detail_state.dart';

class BusinessDetailBloc extends Bloc<BusinessDetailEvent, BusinessDetailState> {
  final GetBusinessDetail getBusinessDetail;
  final BusinessRepository repository; // ✅ pour créer réservation
  final String businessId;

  BusinessDetailBloc({
    required this.getBusinessDetail,
    required this.repository,
    required this.businessId,
  }) : super(BusinessDetailInitial()) {
    on<LoadBusinessDetail>(_onLoadBusinessDetail);
    on<MakeReservation>(_onMakeReservation); // ✅ nouveau
  }

  void _onLoadBusinessDetail(LoadBusinessDetail event, Emitter<BusinessDetailState> emit) async {
    emit(BusinessDetailLoading());
    try {
      final business = await getBusinessDetail(event.businessId);
      emit(BusinessDetailLoaded(business: business));
    } catch (e) {
      emit(BusinessDetailError(message: e.toString()));
    }
  }

  // ✅ Gestion de la réservation
  Future<void> _onMakeReservation(MakeReservation event, Emitter<BusinessDetailState> emit) async {
    emit(ReservationLoading()); // état intermédiaire
    try {
      await repository.createReservation(event.reservation);
      emit(ReservationSuccess());
      // Optionnel : recharger le business si besoin
      add(LoadBusinessDetail(businessId));
    } catch (e) {
      emit(ReservationError(message: e.toString()));
    }
  }
}