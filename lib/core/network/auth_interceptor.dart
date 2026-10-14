import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vclane_client/core/constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final FirebaseAuth _auth;
  final Dio _verifyClient;
  String? _sessionToken;

  AuthInterceptor({FirebaseAuth? auth, Dio? verifyClient})
      : _auth = auth ?? FirebaseAuth.instance,
        _verifyClient = verifyClient ?? Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));

  Future<void> _ensureSession() async {
    if (_sessionToken != null) return;

    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final idToken = await user.getIdToken();
    final response = await _verifyClient.post(
      '/api/auth/verify',
      data: {'idToken': idToken},
    );
    _sessionToken = response.data['accessToken'] as String;
  }

  void invalidateSession() {
    _sessionToken = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      await _ensureSession();
      options.headers['Authorization'] = 'Bearer $_sessionToken';
      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(requestOptions: options, error: e),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _sessionToken = null;
      try {
        await _ensureSession();
        err.requestOptions.headers['Authorization'] = 'Bearer $_sessionToken';
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {}
    }
    handler.next(err);
  }
}
