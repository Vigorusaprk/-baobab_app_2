import 'package:baobabe_0_2/features/business_detail/data/offer_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'business_detail_event.dart';
part 'business_detail_state.dart';

/// Charge la fiche d'un commerçant : le commerce **et** son catalogue, en un
/// seul appel.
///
/// L'écran et sa section catalogue interrogeaient chacun de leur côté la même
/// Edge Function. Le bloc fait désormais l'appel une fois et distribue — la
/// section reçoit ses offres, elle ne les cherche plus.
///
/// Il ne fait que lire : commander et réserver se jouent sur la fiche d'une
/// offre ([OfferDetailCubit]).
class BusinessDetailBloc
    extends Bloc<BusinessDetailEvent, BusinessDetailState> {
  final OfferApiService service;

  BusinessDetailBloc({OfferApiService? service})
    : service = service ?? OfferApiService(),
      super(const BusinessDetailState()) {
    on<LoadBusinessDetail>(_onLoadBusinessDetail);
  }

  Future<void> _onLoadBusinessDetail(
    LoadBusinessDetail event,
    Emitter<BusinessDetailState> emit,
  ) async {
    emit(state.copyWith(detailStatus: BusinessDetailStatus.loading));
    try {
      final page = await service.getPage(event.businessId);
      emit(
        state.copyWith(
          detailStatus: BusinessDetailStatus.loaded,
          business: page.business,
          offers: page.catalogue.offers,
          capabilities: page.catalogue.capabilities,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          detailStatus: BusinessDetailStatus.error,
          detailErrorMessage: 'Impossible de charger ce commerce.',
        ),
      );
    }
  }
}
