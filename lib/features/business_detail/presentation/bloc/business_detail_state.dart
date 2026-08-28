part of 'business_detail_bloc.dart';

enum BusinessDetailStatus { initial, loading, loaded, error }

class BusinessDetailState extends Equatable {
  final Business? business;
  final BusinessDetailStatus detailStatus;
  final String? detailErrorMessage;

  const BusinessDetailState({
    this.business,
    this.detailStatus = BusinessDetailStatus.initial,
    this.detailErrorMessage,
  });

  BusinessDetailState copyWith({
    Business? business,
    BusinessDetailStatus? detailStatus,
    String? detailErrorMessage,
  }) {
    return BusinessDetailState(
      business: business ?? this.business,
      detailStatus: detailStatus ?? this.detailStatus,
      detailErrorMessage: detailErrorMessage ?? this.detailErrorMessage,
    );
  }

  @override
  List<Object?> get props => [business, detailStatus, detailErrorMessage];
}
