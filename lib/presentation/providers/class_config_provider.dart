import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vclane_client/data/datasources/class_config_remote_datasource.dart';
import 'package:vclane_client/data/repositories/class_config_repository_impl.dart';
import 'package:vclane_client/domain/entities/vehicle_class_selection.dart';
import 'package:vclane_client/domain/repositories/class_config_repository.dart';

final classConfigDataSourceProvider = Provider<ClassConfigRemoteDataSource>((
  ref,
) {
  return ClassConfigRemoteDataSource(FirebaseFirestore.instance);
});

final classConfigRepositoryProvider = Provider<ClassConfigRepository>((ref) {
  return ClassConfigRepositoryImpl(ref.watch(classConfigDataSourceProvider));
});

final enabledClassesProvider =
    FutureProvider.family<VehicleClassSelection, String>((ref, deviceId) {
      return ref.watch(classConfigRepositoryProvider).getEnabledClasses(deviceId);
    });
