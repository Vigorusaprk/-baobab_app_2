part of 'business_detail_bloc.dart';

enum BusinessDetailStatus { initial, loading, loaded, error }

class BusinessDetailState extends Equatable {
  final Business? business;

  /// Le catalogue, reçu dans la même réponse que le commerce.
  final List<Offer> offers;
  final BusinessCapabilities? capabilities;

  final BusinessDetailStatus detailStatus;
  final String? detailErrorMessage;

  const BusinessDetailState({
    this.business,
    this.offers = const [],
    this.capabilities,
    this.detailStatus = BusinessDetailStatus.initial,
    this.detailErrorMessage,
  });

  BusinessDetailState copyWith({
    Business? business,
    List<Offer>? offers,
    BusinessCapabilities? capabilities,
    BusinessDetailStatus? detailStatus,
    String? detailErrorMessage,
  }) {
    return BusinessDetailState(
      business: business ?? this.business,
      offers: offers ?? this.offers,
      capabilities: capabilities ?? this.capabilities,
      detailStatus: detailStatus ?? this.detailStatus,
      detailErrorMessage: detailErrorMessage ?? this.detailErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    business,
    offers,
    capabilities,
    detailStatus,
    detailErrorMessage,
  ];
}
