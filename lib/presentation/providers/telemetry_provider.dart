import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vclane_client/domain/entities/telemetry.dart';
import 'package:vclane_client/data/datasources/telemetry_remote_datasource.dart';
import 'package:vclane_client/data/repositories/telemetry_repository_impl.dart';
import 'package:vclane_client/domain/repositories/telemetry_repository.dart';

final telemetryDataSourceProvider = Provider<TelemetryRemoteDataSource>((ref) {
  return TelemetryRemoteDataSource(
    FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://vclane-default-rtdb.asia-southeast1.firebasedatabase.app',
    ),
  );
});

final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  return TelemetryRepositoryImpl(ref.watch(telemetryDataSourceProvider));
});

final telemetryProvider = StreamProvider.family<Telemetry?, String>((
  ref,
  deviceId,
) {
  return ref.watch(telemetryRepositoryProvider).watchTelemetry(deviceId);
});
