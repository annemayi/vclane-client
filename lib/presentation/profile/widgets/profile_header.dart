import 'package:flutter/material.dart';
import 'package:vclane_client/domain/entities/user.dart';
import 'package:vclane_client/core/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : '?';

    final roleLabel = user.role[0].toUpperCase() + user.role.substring(1);

    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary,
            backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
            child: hasPhoto
                ? null
                : Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 34,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              roleLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
