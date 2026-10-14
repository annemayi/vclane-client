import 'device_status.dart';

class Device {
  final String id;
  final String name;
  final String location;
  final DeviceStatus status;
  final String firmwareVersion;
  final String rtspUrl;
  final DateTime createdAt;
  final String? groupId;

  const Device({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.firmwareVersion,
    required this.rtspUrl,
    required this.createdAt,
    this.groupId,
  });

  Device copyWith({
    String? id,
    String? name,
    String? location,
    DeviceStatus? status,
    String? firmwareVersion,
    String? rtspUrl,
    DateTime? createdAt,
    String? groupId,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      rtspUrl: rtspUrl ?? this.rtspUrl,
      createdAt: createdAt ?? this.createdAt,
      groupId: groupId ?? this.groupId,
    );
  }
}
