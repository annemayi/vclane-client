import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/domain/entities/device_status.dart';
import 'package:vclane_client/presentation/providers/device_provider.dart';
import 'package:vclane_client/presentation/dashboard/widgets/quick_stats_row.dart';
import 'package:vclane_client/presentation/dashboard/widgets/device_summary_card.dart';
import 'package:vclane_client/presentation/dashboard/widgets/group_summary_card.dart';
import 'package:vclane_client/presentation/shared/widgets/loading_indicator.dart';
import 'package:vclane_client/presentation/shared/widgets/empty_state.dart';

enum _ViewMode { all, byGroup }

class DashboardScreen extends ConsumerWidget {
  final void Function(String path)? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(deviceListProvider);
    final viewMode = ValueNotifier<_ViewMode>(_ViewMode.all);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () => onNavigate?.call('/profile'),
          ),
        ],
        elevation: 0,
      ),
      body: devicesAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading devices...'),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.offline),
          ),
        ),
        data: (devices) {
          final online = devices
              .where((d) => d.status == DeviceStatus.online)
              .length;

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OPERATOR DASHBOARD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(text: 'Live Traffic '),
                          TextSpan(
                            text: 'Overview',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a device to open its live monitoring view.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<_ViewMode>(
                valueListenable: viewMode,
                builder: (context, mode, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SegmentedButton<_ViewMode>(
                      segments: const [
                        ButtonSegment(
                          value: _ViewMode.all,
                          label: Text('All Devices'),
                          icon: Icon(Icons.devices, size: 18),
                        ),
                        ButtonSegment(
                          value: _ViewMode.byGroup,
                          label: Text('By Group'),
                          icon: Icon(Icons.people_outline, size: 18),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (selected) =>
                          viewMode.value = selected.first,
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<_ViewMode>(
                valueListenable: viewMode,
                builder: (context, mode, _) {
                  if (mode == _ViewMode.all) {
                    return Column(
                      children: [
                        QuickStatsRow(
                          stats: [
                            // TODO: Use dynamic active signals count from backend
                            QuickStat(
                              value: '0 / ${devices.length}',
                              label: 'Active Signals',
                              icon: Icons.campaign,
                            ),
                            QuickStat(
                              value: '$online',
                              label: 'Cameras Online',
                              icon: Icons.videocam,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...devices.map(
                          (device) => DeviceSummaryCard(
                            device: device,
                            onViewInfo: () =>
                                onNavigate?.call('/devices/${device.id}'),
                            onStreamTap: () => onNavigate?.call(
                              '/devices/${device.id}/stream',
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return _GroupView(onNavigate: onNavigate);
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _GroupView extends ConsumerWidget {
  final void Function(String path)? onNavigate;

  const _GroupView({this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupListProvider);
    final devicesByGroup = ref.watch(devicesByGroupProvider);

    return groupsAsync.when(
      loading: () => const LoadingIndicator(message: 'Loading groups...'),
      error: (e, _) => Center(
        child: Text(
          'Error: $e',
          style: const TextStyle(color: AppColors.offline),
        ),
      ),
      data: (groups) {
        if (groups.isEmpty) {
          return const EmptyState(message: 'No groups configured');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '${groups.length} group${groups.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...groups.map((group) {
              final groupDevices = devicesByGroup[group.id] ?? [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GroupSummaryCard(
                  group: group,
                  devices: groupDevices,
                  onNavigate: onNavigate,
                ),
              );
            }),
            if (devicesByGroup.containsKey(null)) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Ungrouped',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ...devicesByGroup[null]!.map(
                (device) => DeviceSummaryCard(
                  device: device,
                  onViewInfo: () => onNavigate?.call('/devices/${device.id}'),
                  onStreamTap: () =>
                      onNavigate?.call('/devices/${device.id}/stream'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
