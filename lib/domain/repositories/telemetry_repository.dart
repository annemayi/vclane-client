import 'package:vclane_client/domain/entities/telemetry.dart';

abstract class TelemetryRepository {
  Stream<Telemetry?> watchTelemetry(String deviceId);
}
