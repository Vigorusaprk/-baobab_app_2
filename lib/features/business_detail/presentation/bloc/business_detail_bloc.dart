import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_business_detail.dart';


part 'business_detail_event.dart';
part 'business_detail_state.dart';

class BusinessDetailBloc extends Bloc<BusinessDetailEvent, BusinessDetailState> {
  final GetBusinessDetail getBusinessDetail;
  final String businessId;

  BusinessDetailBloc({
    required this.getBusinessDetail,
    required this.businessId,
  }) : super(BusinessDetailInitial()) {
    on<LoadBusinessDetail>(_onLoadBusinessDetail);
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
}