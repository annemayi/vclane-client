import 'package:vclane_client/core/network/api_client.dart';

class SignalOverrideRemoteDataSource {
  final ApiClient _apiClient;

  SignalOverrideRemoteDataSource(this._apiClient);

  Future<void> overrideSignal(String deviceId, String targetSignal, {int? durationSeconds}) async {
    await _apiClient.dio.post(
      '/api/devices/$deviceId/signal',
      data: {
        'targetSignal': targetSignal,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
      },
    );
  }
}
