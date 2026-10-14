import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vclane_client/domain/entities/device.dart';
import 'package:vclane_client/data/models/device_model.dart';
import 'package:vclane_client/core/constants/firestore_constants.dart';

class DeviceRemoteDataSource {
  final FirebaseFirestore _firestore;

  DeviceRemoteDataSource(this._firestore);

  Stream<List<Device>> watchDevices() {
    return _firestore
        .collection(FirestoreConstants.devices)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DeviceModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<Device?> watchDevice(String id) {
    return _firestore
        .collection(FirestoreConstants.devices)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? DeviceModel.fromFirestore(doc) : null);
  }
}
