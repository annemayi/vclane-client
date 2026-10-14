import 'package:vclane_client/domain/entities/device.dart';
import 'package:vclane_client/domain/repositories/device_repository.dart';

class GetDevicesUseCase {
  final DeviceRepository repository;
  GetDevicesUseCase(this.repository);

  Stream<List<Device>> execute() => repository.watchDevices();
}
