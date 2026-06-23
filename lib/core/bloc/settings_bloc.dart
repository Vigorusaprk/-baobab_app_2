import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- ÉTATS DU CUBIT ---
abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final Map<String, dynamic> userProfile;
  final User userAuth; // Données issues de auth.users

  const SettingsLoaded({required this.userProfile, required this.userAuth});
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
}

// --- LOGIQUE DU CUBIT ---
class SettingsCubit extends Cubit<SettingsState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  SettingsCubit() : super(SettingsInitial());

  Future<void> loadUserProfile() async {
    emit(SettingsLoading());
    try {
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        emit(const SettingsError("Aucun utilisateur connecté."));
        return;
      }

      // 🔄 Récupération des données de la table publique 'user_profile'
      final response = await _supabase
          .from('user_profile')
          .select()
          .eq('user_id', currentUser.id) // Filtre sur l'ID de l'utilisateur connecté
          .maybeSingle(); // Retourne un seul élément ou null s'il n'existe pas encore

      if (response == null) {
        // Si le profil n'existe pas encore dans la table publique, on passe des données par défaut
        emit(SettingsLoaded(
          userProfile: {
            'name': currentUser.userMetadata?['name'] ?? 'Utilisateur',
            'phone': '',
          },
          userAuth: currentUser,
        ));
      } else {
        emit(SettingsLoaded(userProfile: response, userAuth: currentUser));
      }
    } catch (e) {
      emit(SettingsError("Impossible de charger le profil : $e"));
    }
  }
}