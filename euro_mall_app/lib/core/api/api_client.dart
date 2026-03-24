import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_environment.dart';
import 'api_exception.dart';
import '../../data/auth_token_store.dart';

/// HTTP client for Euro Mall API (`AppEnvironment.apiBaseUrl`).
///
/// Dio joins [baseUrl] with paths using [Uri.resolve]. Without a **trailing
/// slash** on the base, relative paths can incorrectly drop the last segment
/// (e.g. `/api/v1` + `app/config` → `/api/app/config`). Leading slashes on
/// paths replace the whole path. We normalize both so requests hit `/api/v1/...`.
class ApiClient {
  ApiClient({required AuthTokenStore auth}) : _auth = auth {
    _dio = Dio(
      BaseOptions(
        baseUrl: _normalizeBaseUrl(AppEnvironment.apiBaseUrl),
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final t = _auth.token;
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          }
          if (kDebugMode) {
            debugPrint('[API] ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            debugPrint('[API] error: ${e.message}');
          }
          handler.next(e);
        },
      ),
    );
  }

  final AuthTokenStore _auth;
  late final Dio _dio;

  static String _normalizeBaseUrl(String url) =>
      url.endsWith('/') ? url : '$url/';

  /// Relative path segments only (no leading `/`).
  static String _relativePath(String path) =>
      path.startsWith('/') ? path.substring(1) : path;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _relativePath(path),
        queryParameters: queryParameters,
      );
      final data = res.data;
      if (data == null) {
        throw ApiException('Empty response', statusCode: res.statusCode);
      }
      return data;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        _relativePath(path),
        data: data,
        queryParameters: queryParameters,
      );
      return res.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        _relativePath(path),
        data: data,
        queryParameters: queryParameters,
      );
      return res.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.delete<Map<String, dynamic>>(
        _relativePath(path),
        data: data,
        queryParameters: queryParameters,
      );
      return res.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  ApiException _mapDio(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    String msg = e.message ?? 'Network error';
    if (data is Map && data['message'] != null) {
      msg = data['message'].toString();
    } else if (data is String && data.isNotEmpty) {
      msg = data;
    }
    return ApiException(msg, statusCode: code);
  }
}
