class SignalOverride {
  final String deviceId;
  final String? groupId;
  final String targetSignal;
  final String requestedBy;
  final String status;
  final DateTime requestedAt;
  final DateTime expiresAt;

  const SignalOverride({
    required this.deviceId,
    this.groupId,
    required this.targetSignal,
    required this.requestedBy,
    required this.status,
    required this.requestedAt,
    required this.expiresAt,
  });
}
