import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

List<dynamic> getSpaTreatmentsList(Business business) {
  final data = business.specificData['treatments'];
  if (data is List) return data;
  if (data is Map) return [data];
  return [];
}

List<String> getSpaTherapistNames(Business business) {
  final therapists = business.specificData['therapists'];
  if (therapists is List) {
    return therapists.map((t) {
      if (t is Map) return t['name']?.toString() ?? '';
      return t.toString();
    }).where((name) => name.isNotEmpty).toList();
  }
  return [];
}
