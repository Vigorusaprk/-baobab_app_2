class TravelReservationData {
  String? destination;
  DateTime? departureDate;
  int numberOfPassengers = 1;
  String? fullName;
  String? phoneNumber;
  String? notes;

  double calculateTotal() {
    double pricePerTicket = (destination == "Paris") ? 750.0 : 120.0;
    return pricePerTicket * numberOfPassengers;
  }
}
