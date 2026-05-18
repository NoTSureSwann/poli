import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.timeout,
        receiveTimeout: ApiConstants.timeout,
        sendTimeout: ApiConstants.timeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    )..interceptors.addAll([AuthInterceptor(), ErrorInterceptor()]);
  }

  static final DioClient instance = DioClient._internal();

  late final Dio _dio;
  Dio get dio => _dio;
}
