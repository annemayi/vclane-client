import 'package:vclane_client/domain/entities/device.dart';

abstract class DeviceRepository {
  Stream<List<Device>> watchDevices();
  Stream<Device?> watchDevice(String id);
  Future<void> overrideSignal(String deviceId, String targetSignal, {int? durationSeconds});
}
