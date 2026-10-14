import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vclane_client/core/constants/vehicle_classes.dart';
import 'package:vclane_client/domain/entities/vehicle_class_selection.dart';

class VehicleClassSelectionModel {
  /// Reads devices/{id}.detectionConfig.enabledClasses. Absent config or
  /// non-bool values yield no entry (i.e. enabled by default).
  static VehicleClassSelection fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    final config = data?[VehicleClasses.detectionConfigField];
    final raw = config is Map ? config[VehicleClasses.enabledClassesField] : null;
    if (raw is! Map) return const VehicleClassSelection();
    return VehicleClassSelection({
      for (final e in raw.entries)
        if (e.value is bool) e.key as String: e.value as bool,
    });
  }

  static Map<String, bool> toFirestore(VehicleClassSelection selection) {
    // Last line of defense: never persist an emergency class as false, even
    // if the selection was built (or read back from Firestore) with one.
    return {
      ...selection.enabled,
      for (final id in VehicleClassSelection.alwaysEnabled) id: true,
    };
  }
}
