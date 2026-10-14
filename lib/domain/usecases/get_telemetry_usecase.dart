import 'package:vclane_client/domain/entities/telemetry.dart';
import 'package:vclane_client/domain/repositories/telemetry_repository.dart';

class GetTelemetryUseCase {
  final TelemetryRepository repository;
  GetTelemetryUseCase(this.repository);

  Stream<Telemetry?> execute(String deviceId) {
    return repository.watchTelemetry(deviceId);
  }
}
