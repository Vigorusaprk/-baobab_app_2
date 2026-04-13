class ReservationModel {
  final String businessId;
  final String userId;
  final String type;
  final DateTime reservationDate;
  final double totalAmount;
  final Map<String, dynamic> details;

  ReservationModel({
    required this.businessId,
    required this.userId,
    required this.type,
    required this.reservationDate,
    required this.totalAmount,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'user_id': userId,
      'type': type,
      'reservation_date': reservationDate.toIso8601String(),
      'total_amount': totalAmount,
      'details': details,
    };
  }
}