import 'package:vclane_client/data/datasources/class_config_remote_datasource.dart';
import 'package:vclane_client/domain/entities/vehicle_class_selection.dart';
import 'package:vclane_client/domain/repositories/class_config_repository.dart';

class ClassConfigRepositoryImpl implements ClassConfigRepository {
  final ClassConfigRemoteDataSource _dataSource;

  ClassConfigRepositoryImpl(this._dataSource);

  @override
  Future<VehicleClassSelection> getEnabledClasses(String deviceId) {
    return _dataSource.getEnabledClasses(deviceId);
  }

  @override
  Future<void> setEnabledClasses(
    String deviceId,
    VehicleClassSelection selection,
  ) {
    return _dataSource.setEnabledClasses(deviceId, selection);
  }
}
