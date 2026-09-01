import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Ce que le serveur renvoie sur l'utilisateur : qui il est, et où il habite.
class ProfileBundle {
  const ProfileBundle({required this.profile, required this.address});

  final UserProfile profile;

  /// `null` tant que l'utilisateur n'a jamais renseigné d'adresse — distinct
  /// d'une adresse vide, qui voudrait dire qu'il l'a effacée.
  final UserAddress? address;
}

/// Le profil de l'utilisateur, côté réseau.
///
/// Tout passe par `update-profile`, qui écrit dans `users` **et** `user_info`
/// en un seul appel : l'utilisateur remplit un seul formulaire, il ne devrait
/// pas y avoir deux allers-retours ni deux façons d'échouer.
///
/// Le rôle et l'e-mail ne sont pas modifiables. Le rôle est verrouillé plus
/// bas encore, au niveau des privilèges de colonne Postgres — sans quoi
/// n'importe qui se promeut commerçant.
class ProfileApiService {
  ProfileApiService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<ProfileBundle> load() async {
    final response = await _supabase.functions.invoke(
      'update-profile',
      method: HttpMethod.get,
    );
    return _decode(response.data);
  }

  Future<ProfileBundle> save({
    String? name,
    String? phone,
    UserAddress? address,
  }) async {
    final response = await _supabase.functions.invoke(
      'update-profile',
      method: HttpMethod.post,
      body: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address.toJson(),
      },
    );
    return _decode(response.data);
  }

  /// Le référentiel géographique, en un aller-retour.
  Future<List<Province>> locations() async {
    final response = await _supabase.functions.invoke(
      'get-locations',
      method: HttpMethod.get,
    );
    final json = Map<String, dynamic>.from(response.data as Map);
    if (json['error'] != null) throw Exception(json['error'].toString());
    return ((json['provinces'] as List?) ?? const [])
        .map((p) => Province.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();
  }

  ProfileBundle _decode(Object? raw) {
    final json = Map<String, dynamic>.from(raw as Map);
    if (json['error'] != null) throw Exception(json['error'].toString());

    final profile = json['profile'];
    final address = json['address'];
    return ProfileBundle(
      profile: profile is Map
          ? UserProfile.fromJson(Map<String, dynamic>.from(profile))
          : const UserProfile(),
      address: address is Map
          ? UserAddress.fromJson(Map<String, dynamic>.from(address))
          : null,
    );
  }
}
