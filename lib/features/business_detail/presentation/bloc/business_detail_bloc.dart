import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_business_detail.dart';

part 'business_detail_event.dart';
part 'business_detail_state.dart';

/// Charge la fiche d'un commerçant.
///
/// Il ne fait plus que lire : commander et réserver se jouent désormais sur
/// la fiche d'une offre ([OfferDetailCubit]). Le panier et la réservation
/// qui vivaient ici pilotaient les tunnels spécialisés, supprimés avec la
/// section d'actions.
class BusinessDetailBloc
    extends Bloc<BusinessDetailEvent, BusinessDetailState> {
  final GetBusinessDetail getBusinessDetail;

  BusinessDetailBloc({required this.getBusinessDetail})
    : super(const BusinessDetailState()) {
    on<LoadBusinessDetail>(_onLoadBusinessDetail);
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
}
