import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vclane_client/domain/entities/device.dart';
import 'package:vclane_client/domain/entities/device_status.dart';
import 'package:vclane_client/domain/entities/telemetry.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/core/utils/date_formatter.dart';
import 'package:vclane_client/presentation/dashboard/widgets/device_stream_preview.dart';
import 'package:vclane_client/presentation/providers/telemetry_provider.dart';

class DeviceSummaryCard extends ConsumerWidget {
  final Device device;
  final VoidCallback onViewInfo;
  final VoidCallback? onStreamTap;
  const DeviceSummaryCard({
    super.key,
    required this.device,
    required this.onViewInfo,
    this.onStreamTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingsAsync = ref.watch(telemetryProvider(device.id));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewInfo,
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
                padding: const EdgeInsets.fromLTRB(16, 10, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            device.location,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Last seen: ${readingsAsync.valueOrNull?.timestamp.timeAgo() ?? 'Never'}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: device.status),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: DeviceStreamPreview(
                  status: device.status,
                  onTap: onStreamTap,
                ),
              ),
              readingsAsync.when(
                loading: () => _buildSignalBox(reading: null),
                error: (_, __) => _buildSignalBox(reading: null),
                data: (reading) => _buildSignalBox(reading: reading),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalBox({required Telemetry? reading}) {
    final signalLabel = reading?.currentTrafficLightSignal ?? 'N/A';
    final vehicleCount = reading?.vehicleCount ?? 0;
    final isActive = signalLabel.toUpperCase();
    final greenOn = isActive == 'GREEN';
    final yellowOn = isActive == 'YELLOW';
    final redOn = isActive == 'RED';
    final offColor = AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Signal',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      signalLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: greenOn ? AppColors.online : offColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: yellowOn ? AppColors.warning : offColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: redOn ? AppColors.offline : offColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'Today: '),
                TextSpan(
                  text: '$vehicleCount vehicles',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DeviceStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      DeviceStatus.online => (AppColors.online, 'Online'),
      DeviceStatus.offline => (AppColors.offline, 'Offline'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
