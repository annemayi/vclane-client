class VehicleClasses {
  VehicleClasses._();

  /// Firestore location: devices/{deviceId}.detectionConfig.enabledClasses
  /// (map of class -> bool; a missing key means enabled).
  static const String detectionConfigField = 'detectionConfig';
  static const String enabledClassesField = 'enabledClasses';

  /// TODO(before merge): casing is inconsistent (`Jeepney`, `Tricycle`,
  /// `E-bike` vs lowercase) and each string is used verbatim as a Firestore
  /// map key. Confirm every entry matches the model's `detections.class`
  /// output (`YOLO('models/best.pt').names`) EXACTLY, including case.
  static const List<String> ids = <String>[
    'ambulance',
    'bicycle',
    'bus',
    'car',
    'chariot',
    'E-bike',
    'fire truck',
    'Jeepney',
    'motorcycle',
    'police car',
    'Tricycle',
    'truck',
    'van',
  ];
}
