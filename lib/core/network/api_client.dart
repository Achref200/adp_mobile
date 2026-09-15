import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiClient {
  ApiClient({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(BaseOptions(
              // On web, the API normally shares the app's origin (Vercel) —
              // use relative paths. For local testing against a dev backend,
              // run with --dart-define=ADP_API_URL=http://localhost:8080.
              // On mobile, use ADP_API_URL or localhost.
              baseUrl: baseUrl ??
                  const String.fromEnvironment('ADP_API_URL',
                      defaultValue: kIsWeb ? '' : 'http://localhost:8080'),
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 12),
            ));
  final Dio _dio;

  Future<Response<dynamic>> get(String path, {String? accessToken}) =>
      _dio.get(path,
          options: accessToken == null
              ? null
              : Options(headers: {'Authorization': 'Bearer $accessToken'}));
  Future<Response<dynamic>> post(String path,
          {Object? data, String? accessToken}) =>
      _dio.post(path,
          data: data,
          options: accessToken == null
              ? null
              : Options(headers: {'Authorization': 'Bearer $accessToken'}));
  Future<Response<dynamic>> put(String path,
          {Object? data, String? accessToken}) =>
      _dio.put(path,
          data: data,
          options: accessToken == null
              ? null
              : Options(headers: {'Authorization': 'Bearer $accessToken'}));
}
