import 'package:dio/dio.dart';
import 'package:vclane_client/core/constants/app_constants.dart';
import 'package:vclane_client/core/network/auth_interceptor.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({AuthInterceptor? authInterceptor}) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    if (authInterceptor != null) {
      dio.interceptors.add(authInterceptor);
    }
  }
}
