class Telemetry {
  final int vehicleCount;
  final String currentTrafficLightSignal;
  final DateTime timestamp;
  final bool online;

  const Telemetry({
    required this.vehicleCount,
    required this.currentTrafficLightSignal,
    required this.timestamp,
    required this.online,
  });
}
