import 'package:vclane_client/domain/entities/device_status.dart';

class DeviceStatusModel {
  static DeviceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'online':
        return DeviceStatus.online;
      case 'offline':
        return DeviceStatus.offline;
      default:
        return DeviceStatus.offline;
    }
  }

  static String toStringValue(DeviceStatus status) {
    return status.name;
  }
}
