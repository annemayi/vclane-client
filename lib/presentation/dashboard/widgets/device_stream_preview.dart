import 'package:flutter/material.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/domain/entities/device_status.dart';

class DeviceStreamPreview extends StatelessWidget {
  final DeviceStatus status;
  final VoidCallback? onTap;
  const DeviceStreamPreview({super.key, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOnline = status == DeviceStatus.online;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.videoBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isOnline
            ? Stack(
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
                          'Tap to view live stream',
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
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.videocam_off,
                      size: 40,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Camera offline',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Please check the device connection.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
