import 'package:firebase_database/firebase_database.dart';
import 'package:vclane_client/domain/entities/telemetry.dart';
import 'package:vclane_client/data/models/telemetry_model.dart';

class TelemetryRemoteDataSource {
  final FirebaseDatabase _database;

  TelemetryRemoteDataSource(this._database);

  Stream<Telemetry?> watchTelemetry(String deviceId) {
    final ref = _database.ref('telemetry/$deviceId');
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return null;
      return TelemetryModel.fromRtdb(Map<String, dynamic>.from(data));
    });
  }
}
