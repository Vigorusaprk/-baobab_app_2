import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  final Dio _refreshDio = Dio();
  final String baseUrl;

  AuthInterceptor({this.baseUrl = 'http://10.0.2.2:3000/api'});

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
    final shouldTryRefresh =
        err.response?.statusCode == 401 &&
        err.requestOptions.extra['retried'] != true &&
        !err.requestOptions.path.contains('/auth/login') &&
        !err.requestOptions.path.contains('/auth/signup') &&
        !err.requestOptions.path.contains('/auth/refresh');

    if (!shouldTryRefresh) {
      handler.next(err);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearTokens(prefs);
      handler.next(err);
      return;
    }

    try {
      final refreshResponse = await _refreshDio.post(
        '$baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken =
          (refreshResponse.data['accessToken'] ?? refreshResponse.data['token']) as String;
      final newRefreshToken = (refreshResponse.data['refreshToken'] ?? '') as String;

      await prefs.setString(_tokenKey, newAccessToken);
      if (newRefreshToken.isNotEmpty) {
        await prefs.setString(_refreshTokenKey, newRefreshToken);
      }

      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      requestOptions.extra['retried'] = true;

      final clonedResponse = await _refreshDio.fetch(requestOptions);
      handler.resolve(clonedResponse);
      return;
    } catch (_) {
      await _clearTokens(prefs);
    }

    handler.next(err);
  }

  Future<void> _clearTokens(SharedPreferences prefs) async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove('auth_expiry');
    await prefs.remove('user_data');
  }
}