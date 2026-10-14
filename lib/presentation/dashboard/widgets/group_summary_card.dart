import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/domain/entities/device.dart';
import 'package:vclane_client/domain/entities/device_status.dart';
import 'package:vclane_client/domain/entities/group.dart';
import 'package:vclane_client/presentation/dashboard/widgets/device_summary_card.dart';

class GroupSummaryCard extends ConsumerWidget {
  final Group group;
  final List<Device> devices;
  final void Function(String path)? onNavigate;

  const GroupSummaryCard({
    super.key,
    required this.group,
    required this.devices,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = devices.where((d) => d.status == DeviceStatus.online).length;
    final offline = devices
        .where((d) => d.status == DeviceStatus.offline)
        .length;
    final isExpanded = ValueNotifier(false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (group.description != null)
                              Text(
                                group.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${devices.length} junction${devices.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      _StatusChip(
                        count: online,
                        label: 'Online',
                        color: AppColors.online,
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        count: offline,
                        label: 'Offline',
                        color: AppColors.offline,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isExpanded,
                      builder: (context, expanded, _) {
                        return TextButton.icon(
                          onPressed: () => isExpanded.value = !expanded,
                          icon: Icon(
                            expanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            expanded ? 'Hide junctions' : 'Show junctions',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isExpanded,
            builder: (context, expanded, _) {
              if (!expanded) return const SizedBox.shrink();
              return Column(
                children: devices.map((device) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DeviceSummaryCard(
                      device: device,
                      onViewInfo: () =>
                          onNavigate?.call('/devices/${device.id}'),
                      onStreamTap: () =>
                          onNavigate?.call('/devices/${device.id}/stream'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatusChip({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: count > 0 ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: count > 0 ? color : color.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
