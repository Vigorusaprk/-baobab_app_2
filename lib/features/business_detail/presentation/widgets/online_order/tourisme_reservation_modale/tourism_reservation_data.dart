class TourismReservationData {
  List<String> selectedActivities = [];
  DateTime? activityDate;
  int numberOfParticipants = 1;
  String? fullName;
  String? phoneNumber;
  String? notes;

  double calculateTotal(List<dynamic> activities) {
    double total = 0.0;
    for (final name in selectedActivities) {
      for (final a in activities) {
        if (a is Map && a['name'] == name) {
          total += (a['price'] as num?)?.toDouble() ?? 0.0;
          break;
        }
      }
    }
    return total * numberOfParticipants;
  }

  List<Map<String, dynamic>> getSelectedActivitiesWithPrices(
    List<dynamic> allActivities,
  ) {
    List<Map<String, dynamic>> result = [];
    for (final name in selectedActivities) {
      for (final a in allActivities) {
        if (a is Map && a['name'] == name) {
          result.add({
            'name': name,
            'price': a['price'],
            'duration': a['duration'],
            'location': a['location'],
          });
          break;
        }
      }
    }
    return result;
  }
}
