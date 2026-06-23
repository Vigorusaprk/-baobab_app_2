import 'package:baobabe_0_2/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> signUp({required String name, required String email, required String password, String? phone});
  Future<void> logout();
  Future<UserModel?> checkAuthStatus();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final response = await supabase.auth.signInWithPassword(email: email, password: password);
    if (response.user == null) throw Exception("Connexion échouée");

    final userData = await supabase.from('users').select().eq('id', response.user!.id).maybeSingle();
    if (userData == null) throw Exception("Profil introuvable");
    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel> signUp({required String name, required String email, required String password, String? phone}) async {
    final response = await supabase.auth.signUp(email: email, password: password, data: {'name': name, 'phone': phone});

    if (response.user == null) throw Exception("Inscription échouée");

    final newUserMap = {'id': response.user!.id, 'name': name, 'email': email, 'phone': phone};
    await supabase.from('users').insert(newUserMap);

    return UserModel.fromJson(newUserMap);
  }

  @override
  Future<void> logout() => supabase.auth.signOut();

  @override
  Future<UserModel?> checkAuthStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final userData = await supabase.from('users').select().eq('id', user.id).maybeSingle();
    return userData != null ? UserModel.fromJson(userData) : null;
  }
}