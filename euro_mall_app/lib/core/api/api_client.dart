import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_environment.dart';
import 'api_exception.dart';
import '../../data/auth_token_store.dart';

/// HTTP client for Euro Mall API (`AppEnvironment.apiBaseUrl`).
class ApiClient {
  ApiClient({required AuthTokenStore auth}) : _auth = auth {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseUrl,
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

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        path,
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
        path,
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
        path,
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
