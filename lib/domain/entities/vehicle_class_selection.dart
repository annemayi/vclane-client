class VehicleClassSelection {
  /// Safety lock: emergency-vehicle classes can never be switched off, so
  /// emergency green-light priority cannot be disabled by a maker. Must match
  /// the edge's `emergency_classes` labels exactly (case-sensitive).
  static const Set<String> alwaysEnabled = {
    'ambulance',
    'fire truck',
    'police car',
  };

  /// Per-class enabled flags. A class with no entry is enabled by default.
  final Map<String, bool> enabled;

  const VehicleClassSelection([this.enabled = const {}]);

  bool isLocked(String classId) => alwaysEnabled.contains(classId);

  bool isEnabled(String classId) =>
      isLocked(classId) || (enabled[classId] ?? true);

  /// Ignored for locked classes.
  VehicleClassSelection withEnabled(String classId, bool value) {
    if (isLocked(classId)) return this;
    return VehicleClassSelection({...enabled, classId: value});
  }

  /// Locked classes are skipped.
  VehicleClassSelection withAll(Iterable<String> classIds, bool value) {
    return VehicleClassSelection({
      ...enabled,
      for (final id in classIds)
        if (!isLocked(id)) id: value,
    });
  }
}
