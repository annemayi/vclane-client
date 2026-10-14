import 'package:vclane_client/domain/entities/device.dart';
import 'package:vclane_client/domain/repositories/device_repository.dart';

class GetDeviceDetailUseCase {
  final DeviceRepository repository;
  GetDeviceDetailUseCase(this.repository);

  Stream<Device?> execute(String id) => repository.watchDevice(id);
}
