import 'package:rxdart/rxdart.dart';
import 'package:vclane_client/domain/entities/device.dart';
import 'package:vclane_client/domain/entities/device_status.dart';
import 'package:vclane_client/domain/entities/telemetry.dart';
import 'package:vclane_client/domain/repositories/device_repository.dart';
import 'package:vclane_client/data/datasources/device_remote_datasource.dart';
import 'package:vclane_client/data/datasources/telemetry_remote_datasource.dart';
import 'package:vclane_client/data/datasources/signal_override_remote_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _remoteDataSource;
  final TelemetryRemoteDataSource _telemetryDataSource;
  final SignalOverrideRemoteDataSource _signalOverrideDataSource;

  DeviceRepositoryImpl(
    this._remoteDataSource,
    this._telemetryDataSource,
    this._signalOverrideDataSource,
  );

  @override
  Stream<List<Device>> watchDevices() {
    return _remoteDataSource.watchDevices().switchMap((devices) {
      if (devices.isEmpty) return Stream.value(<Device>[]);
      final streams = devices.map(_withStatus).toList();
      return Rx.combineLatestList(streams);
    });
  }

  @override
  Stream<Device?> watchDevice(String id) {
    return Rx.combineLatest2(
      _remoteDataSource.watchDevice(id),
      _telemetryDataSource.watchTelemetry(id),
      (Device? device, Telemetry? telemetry) {
        if (device == null) return null;
        return _applyStatus(device, telemetry);
      },
    );
  }

  Stream<Device> _withStatus(Device device) {
    return _telemetryDataSource
        .watchTelemetry(device.id)
        .map((telemetry) => _applyStatus(device, telemetry));
  }

  Device _applyStatus(Device device, Telemetry? telemetry) {
    final isOnline = telemetry?.online ?? false;
    return device.copyWith(
      status: isOnline ? DeviceStatus.online : DeviceStatus.offline,
    );
  }

  @override
  Future<void> overrideSignal(String deviceId, String targetSignal, {int? durationSeconds}) async {
    await _signalOverrideDataSource.overrideSignal(deviceId, targetSignal, durationSeconds: durationSeconds);
  }
}
