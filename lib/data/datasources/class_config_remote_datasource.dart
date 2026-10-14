import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vclane_client/core/constants/firestore_constants.dart';
import 'package:vclane_client/core/constants/vehicle_classes.dart';
import 'package:vclane_client/data/models/vehicle_class_selection_model.dart';
import 'package:vclane_client/domain/entities/vehicle_class_selection.dart';

class ClassConfigRemoteDataSource {
  final FirebaseFirestore _firestore;

  ClassConfigRemoteDataSource(this._firestore);

  Future<VehicleClassSelection> getEnabledClasses(String deviceId) async {
    final doc = await _firestore
        .collection(FirestoreConstants.devices)
        .doc(deviceId)
        .get();
    return VehicleClassSelectionModel.fromFirestore(doc);
  }

  /// Replaces devices/{id}.detectionConfig.enabledClasses only; other fields
  /// (and other detectionConfig keys) are untouched. Fails if the device doc
  /// does not exist.
  Future<void> setEnabledClasses(
    String deviceId,
    VehicleClassSelection selection,
  ) {
    return _firestore
        .collection(FirestoreConstants.devices)
        .doc(deviceId)
        .update({
          '${VehicleClasses.detectionConfigField}.${VehicleClasses.enabledClassesField}':
              VehicleClassSelectionModel.toFirestore(selection),
        });
  }
}
