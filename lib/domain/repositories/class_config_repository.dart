import 'package:vclane_client/domain/entities/vehicle_class_selection.dart';

abstract class ClassConfigRepository {
  Future<VehicleClassSelection> getEnabledClasses(String deviceId);
  Future<void> setEnabledClasses(
    String deviceId,
    VehicleClassSelection selection,
  );
}
