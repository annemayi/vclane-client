import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vclane_client/domain/entities/device.dart';
import 'package:vclane_client/data/models/device_status_model.dart';

class DeviceModel {
  static Device fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Device(
      id: doc.id,
      name: data['name'] as String? ?? '',
      location: data['location'] as String? ?? '',
      status: DeviceStatusModel.fromString(
        data['status'] as String? ?? 'offline',
      ),
      firmwareVersion: data['firmwareVersion'] as String? ?? '',
      rtspUrl: data['rtspUrl'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      groupId: data['groupId'] as String?,
    );
  }

  static Map<String, dynamic> toFirestore(Device device) {
    return {
      'name': device.name,
      'location': device.location,
      'status': DeviceStatusModel.toStringValue(device.status),
      'firmwareVersion': device.firmwareVersion,
      'rtspUrl': device.rtspUrl,
      'createdAt': Timestamp.fromDate(device.createdAt),
      'groupId': device.groupId,
    };
  }
}
