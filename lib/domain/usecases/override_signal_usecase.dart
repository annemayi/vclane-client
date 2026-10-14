import 'package:vclane_client/domain/repositories/device_repository.dart';

class OverrideSignalUseCase {
  final DeviceRepository repository;

  OverrideSignalUseCase(this.repository);

  static const _validSignals = {'RED', 'YELLOW', 'GREEN'};

  Future<void> execute(String deviceId, String targetSignal, {int? durationSeconds}) async {
    final signal = targetSignal.toUpperCase();
    if (!_validSignals.contains(signal)) {
      throw ArgumentError('Invalid signal: $targetSignal. Must be RED, YELLOW, or GREEN.');
    }
    await repository.overrideSignal(deviceId, signal, durationSeconds: durationSeconds);
  }
}
