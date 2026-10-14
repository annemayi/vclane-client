import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/presentation/providers/auth_provider.dart';
import 'package:vclane_client/presentation/profile/widgets/profile_header.dart';
import 'package:vclane_client/presentation/shared/widgets/loading_indicator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authRepositoryProvider).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final user = switch (authState) {
      Authenticated(user: final u) => u,
      _ => null,
    };

    if (user == null) return const LoadingIndicator();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/profile/edit'),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        children: [
          ProfileHeader(user: user),
          const SizedBox(height: 8),
          _buildSection('Account', [
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Display Name',
              subtitle: user.displayName,
            ),
            _SettingsTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: user.email,
            ),
            _SettingsTile(
              icon: Icons.location_on_outlined,
              title: 'Address',
              subtitle: user.address.isEmpty ? 'Not set' : user.address,
            ),
            _SettingsTile(
              icon: Icons.phone_outlined,
              title: 'Phone Number',
              subtitle: user.phoneNumber.isEmpty ? 'Not set' : user.phoneNumber,
            ),
          ]),
          const SizedBox(height: 8),
          _buildSection('Preferences', [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: 'Light',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          _buildSection('About', [
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: 'v1.0.0',
            ),
          ]),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout, color: AppColors.offline),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, color: AppColors.offline),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.offline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AppColors.primary,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: trailing ?? const SizedBox.shrink(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          visualDensity: const VisualDensity(vertical: -1),
        ),
        const Divider(height: 1, indent: 56, color: AppColors.divider),
      ],
    );
  }
}
