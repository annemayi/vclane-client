import 'package:flutter/material.dart';
import 'package:vclane_client/domain/entities/device_status.dart';
import 'package:vclane_client/core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final DeviceStatus status;
  final bool compact;
  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      DeviceStatus.online => (AppColors.online, 'Online'),
      DeviceStatus.offline => (AppColors.offline, 'Offline'),
    };

    if (compact) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }

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
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
