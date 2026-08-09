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

      // La table 'user_profile' interrogée ici auparavant n'existe pas dans
      // le schéma réel (c'est 'users') : l'Edge Function get-me lit la
      // bonne table et crée la ligne à la volée si c'est la première
      // connexion de l'utilisateur.
      final response = await _supabase.functions.invoke(
        'get-me',
        method: HttpMethod.get,
      );
      final profile = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;

      emit(SettingsLoaded(userProfile: profile, userAuth: currentUser));
    } catch (e) {
      emit(SettingsError("Impossible de charger le profil : $e"));
    }
  }
}
