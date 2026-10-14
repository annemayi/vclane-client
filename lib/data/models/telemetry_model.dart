import 'package:vclane_client/domain/entities/telemetry.dart';

class TelemetryModel {
  static Telemetry fromRtdb(Map<String, dynamic> data) {
    return Telemetry(
      vehicleCount: data['vehicleCount'] as int? ?? 0,
      currentTrafficLightSignal:
          data['currentTrafficLightSignal'] as String? ?? 'UNKNOWN',
      timestamp: _parseTimestamp(data['timestamp']),
      online: data['online'] as bool? ?? false,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static Map<String, dynamic> toMap(Telemetry reading) {
    return {
      'vehicleCount': reading.vehicleCount,
      'currentTrafficLightSignal': reading.currentTrafficLightSignal,
      'timestamp': reading.timestamp.toIso8601String(),
    };
  }
}
