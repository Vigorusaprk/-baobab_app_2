import 'package:baobabe_0_2/features/settings/data/profile_api_service.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ProfileStatus { initial, loading, ready, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile = const UserProfile(),
    this.address,
    this.provinces = const [],
    this.saving = false,
    this.message,
  });

  final ProfileStatus status;
  final UserProfile profile;
  final UserAddress? address;
  final List<Province> provinces;
  final bool saving;

  /// Message écrit en cas d'échec. Jamais une exception.
  final String? message;

  /// Ce que l'écran regarde pour décider entre « Compléter mon profil » et
  /// « Modifier le profil ».
  bool get isIncomplete =>
      profile.isIncomplete || address == null || address!.isEmpty;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    UserAddress? address,
    List<Province>? provinces,
    bool? saving,
    String? message,
    bool clearMessage = false,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    address: address ?? this.address,
    provinces: provinces ?? this.provinces,
    saving: saving ?? this.saving,
    message: clearMessage ? null : (message ?? this.message),
  );

  @override
  List<Object?> get props => [
    status,
    profile,
    address,
    provinces,
    saving,
    message,
  ];
}

/// Le profil de l'utilisateur : son identité et son adresse.
///
/// Il est fourni au niveau de l'application parce que trois endroits en ont
/// besoin — l'écran de profil, la feuille de commande (qui pré-remplit
/// l'adresse) et la feuille de réservation (qui pré-remplit le téléphone).
/// Chacun le rechargeant de son côté aurait multiplié les appels et laissé
/// les écrans se contredire.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({ProfileApiService? api})
    : _api = api ?? ProfileApiService(),
      super(const ProfileState());

  final ProfileApiService _api;

  Future<void> load({bool force = false}) async {
    if (!force && state.status == ProfileStatus.ready) return;
    emit(state.copyWith(status: ProfileStatus.loading, clearMessage: true));
    try {
      final bundle = await _api.load();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.ready,
          profile: bundle.profile,
          address: bundle.address,
        ),
      );
    } catch (e) {
      debugPrint('Chargement du profil — échec : $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          message:
              "Votre profil n'a pas pu être chargé. Vérifiez votre connexion "
              'et réessayez.',
        ),
      );
    }
  }

  /// Le référentiel géographique n'est chargé qu'à l'ouverture du formulaire,
  /// et une seule fois : il ne change pas d'une minute à l'autre.
  Future<void> loadProvinces() async {
    if (state.provinces.isNotEmpty) return;
    try {
      final provinces = await _api.locations();
      if (isClosed) return;
      emit(state.copyWith(provinces: provinces));
    } catch (e) {
      // Sans référentiel, les champs restent libres à la saisie : l'écran
      // fonctionne, il propose simplement moins.
      debugPrint('Chargement des provinces — échec : $e');
    }
  }

  /// Enregistre ce que l'utilisateur a saisi.
  ///
  /// Rend `true` si l'écriture a abouti, pour que l'appelant sache s'il peut
  /// refermer sa feuille.
  Future<bool> save({String? name, String? phone, UserAddress? address}) async {
    emit(state.copyWith(saving: true, clearMessage: true));
    try {
      final bundle = await _api.save(
        name: name,
        phone: phone,
        address: address,
      );
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: ProfileStatus.ready,
          profile: bundle.profile,
          address: bundle.address,
          saving: false,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Enregistrement du profil — échec : $e');
      if (isClosed) return false;
      emit(
        state.copyWith(
          saving: false,
          message:
              "Vos informations n'ont pas pu être enregistrées. Réessayez "
              'dans un instant.',
        ),
      );
      return false;
    }
  }
}
