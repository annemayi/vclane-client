import 'package:vclane_client/domain/entities/telemetry.dart';
import 'package:vclane_client/domain/repositories/telemetry_repository.dart';
import 'package:vclane_client/data/datasources/telemetry_remote_datasource.dart';

class TelemetryRepositoryImpl implements TelemetryRepository {
  final TelemetryRemoteDataSource _dataSource;

  TelemetryRepositoryImpl(this._dataSource);

  @override
  Stream<Telemetry?> watchTelemetry(String deviceId) {
    return _dataSource.watchTelemetry(deviceId);
  }
}
