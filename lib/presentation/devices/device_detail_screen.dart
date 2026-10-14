import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/core/utils/date_formatter.dart';
import 'package:vclane_client/domain/entities/device.dart';
import 'package:vclane_client/domain/entities/device_status.dart';
import 'package:vclane_client/domain/entities/telemetry.dart';
import 'package:vclane_client/presentation/providers/device_provider.dart';
import 'package:vclane_client/presentation/providers/telemetry_provider.dart';
import 'package:vclane_client/presentation/shared/widgets/loading_indicator.dart';
import 'package:vclane_client/presentation/devices/widgets/signal_override_dialog.dart';

class DeviceDetailScreen extends ConsumerWidget {
  final String deviceId;
  final void Function(String path)? onNavigate;
  const DeviceDetailScreen({
    super.key,
    required this.deviceId,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceAsync = ref.watch(deviceProvider(deviceId));
    final effectiveReading = ref.watch(effectiveReadingProvider(deviceId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Device Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        elevation: 0,
      ),
      body: deviceAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading device...'),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.offline),
          ),
        ),
        data: (device) {
          if (device == null) {
            return const Center(
              child: Text(
                'Device not found',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            );
          }

          return ListView(
            children: [
              _DeviceHeader(device: device),
              const SizedBox(height: 12),
              _StreamSection(deviceId: deviceId),
              const SizedBox(height: 12),
              _DeviceInfoSection(device: device),
              if (device.groupId != null) ...[
                const SizedBox(height: 12),
                _GroupInfoSection(device: device),
              ],
              const SizedBox(height: 12),
              _TelemetrySection(reading: effectiveReading, deviceId: deviceId),
              const SizedBox(height: 12),
              _OverrideSection(device: device),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _DeviceHeader extends ConsumerWidget {
  final Device device;
  const _DeviceHeader({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(telemetryProvider(device.id)).valueOrNull;
    final lastSeenText = telemetry?.timestamp.timeAgo() ?? 'Never';
    final (Color statusColor, String statusLabel) = switch (device.status) {
      DeviceStatus.online => (AppColors.online, 'Online'),
      DeviceStatus.offline => (AppColors.offline, 'Offline'),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.location,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: const Divider(height: 1, color: AppColors.divider),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                _InfoRow('Device ID', device.id),
                _InfoRow('Firmware', device.firmwareVersion),
                _InfoRow('Last Seen', lastSeenText),
                _InfoRow(
                  'Created',
                  '${device.createdAt.day}/${device.createdAt.month}/${device.createdAt.year}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamSection extends StatelessWidget {
  final String deviceId;
  const _StreamSection({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/devices/$deviceId/stream'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Icon(Icons.live_tv, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Live Stream',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              decoration: BoxDecoration(
                color: AppColors.videoBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.videocam,
                          size: 40,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to play stream',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoSection extends StatelessWidget {
  final Device device;
  const _DeviceInfoSection({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Device Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _InfoRow('Status', device.status.name.toUpperCase()),
                _InfoRow('Firmware', device.firmwareVersion),
                _InfoRow(
                  'RTSP URL',
                  device.rtspUrl.isNotEmpty ? device.rtspUrl : 'Not configured',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetrySection extends StatelessWidget {
  final Telemetry? reading;
  final String deviceId;
  const _TelemetrySection({required this.reading, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final reading = this.reading;
    if (reading == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Telemetry',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Vehicles',
                    value: '${reading.vehicleCount}',
                    icon: Icons.directions_car,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TrafficSignalStat(
                    signal: reading.currentTrafficLightSignal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficSignalStat extends StatelessWidget {
  final String signal;
  const _TrafficSignalStat({required this.signal});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (signal.toUpperCase()) {
      'GREEN' => (AppColors.online, Icons.check_circle),
      'YELLOW' => (AppColors.warning, Icons.warning),
      'RED' => (AppColors.offline, Icons.stop_circle),
      _ => (AppColors.primary.withValues(alpha: 0.5), Icons.help_outline),
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signal',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  signal,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupInfoSection extends ConsumerWidget {
  final Device device;

  const _GroupInfoSection({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProvider(device.groupId!));

    return groupAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (group) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.people_outline,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Group',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    _InfoRow('Name', group?.name ?? 'Unknown'),
                    if (group?.description != null) ...[
                      if (group!.description!.isNotEmpty)
                        _InfoRow('Description', group.description!),
                    ],
                    if (group?.location != null) ...[
                      if (group!.location!.isNotEmpty)
                        _InfoRow('Area', group.location!),
                    ],
                    _InfoRow('Group ID', device.groupId!),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OverrideSection extends ConsumerWidget {
  final Device device;

  const _OverrideSection({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.traffic,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Signal Override',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Force a signal change for this junction and all devices in its group.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _OverrideButton(
                    label: 'RED',
                    color: AppColors.offline,
                    onTap: () => _showOverrideDialog(context, 'RED'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OverrideButton(
                    label: 'GREEN',
                    color: AppColors.online,
                    onTap: () => _showOverrideDialog(context, 'GREEN'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOverrideDialog(BuildContext context, String signal) {
    showDialog(
      context: context,
      builder: (_) => SignalOverrideDialog(
        deviceId: device.id,
        groupId: device.groupId,
        targetSignal: signal,
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              device.groupId != null
                  ? 'Signal override to $signal triggered for group'
                  : 'Signal override to $signal applied',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
}

class _OverrideButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OverrideButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: color,
          backgroundColor: color.withValues(alpha: 0.05),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ),
    );
  }
}
