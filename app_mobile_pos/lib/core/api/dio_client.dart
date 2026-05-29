import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import '../constants/api_constants.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storage.read(key: 'jwt_token');

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e, stackTrace) {
            developer.log(
              'Error al leer el token en el interceptor',
              name: 'api.interceptor',
              error: e,
              stackTrace: stackTrace,
            );
          }
          return handler.next(options);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
