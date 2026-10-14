import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vclane_client/core/constants/stream_constants.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/presentation/providers/device_provider.dart';
import 'package:vclane_client/presentation/shared/widgets/status_badge.dart';
import 'package:vclane_client/presentation/stream/widgets/video_player_widget.dart';

class LiveStreamScreen extends ConsumerWidget {
  final String deviceId;
  const LiveStreamScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceAsync = ref.watch(deviceProvider(deviceId));
    final reading = ref.watch(effectiveReadingProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: deviceAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'Device error: $e',
            style: const TextStyle(color: AppColors.offline),
          ),
        ),
        data: (device) {
          final url = (device?.rtspUrl.isNotEmpty ?? false)
              ? device!.rtspUrl
              : StreamConstants.sampleRtspUrl;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: VideoPlayerWidget(rtspUrl: url)),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black45, Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.black38,
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  context.go('/devices/$deviceId'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              device?.name ?? 'Live Stream',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withValues(
                                alpha: 0.9,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fiber_manual_record,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (device != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusBadge(status: device.status),
                          const SizedBox(height: 8),
                          _infoRow(Icons.location_on, device.location),
                          _infoRow(
                            Icons.memory,
                            'Firmware ${device.firmwareVersion}',
                          ),
                          _infoRow(Icons.videocam, device.rtspUrl),
                          if (reading != null) ...[
                            _infoRow(
                              Icons.directions_car,
                              'Vehicles: ${reading.vehicleCount}',
                            ),
                            _signalRow(reading.currentTrafficLightSignal),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signalRow(String signal) {
    final color = switch (signal.toLowerCase()) {
      'green' => Colors.greenAccent,
      'red' => Colors.redAccent,
      'yellow' || 'amber' => Colors.amber,
      _ => Colors.white70,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.traffic, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Signal: $signal',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}