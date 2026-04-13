import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expiré ou invalide -> déconnexion
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      // Optionnel: rediriger vers login via un service de navigation
    }
    handler.next(err);
  }
}