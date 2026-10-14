import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vclane_client/presentation/providers/auth_provider.dart';
import 'package:vclane_client/presentation/auth/login_screen.dart';
import 'package:vclane_client/presentation/dashboard/dashboard_screen.dart';
import 'package:vclane_client/presentation/devices/device_detail_screen.dart';
import 'package:vclane_client/presentation/stream/live_stream_screen.dart';
import 'package:vclane_client/presentation/profile/profile_screen.dart';
import 'package:vclane_client/presentation/profile/edit_profile_screen.dart';
import 'package:vclane_client/presentation/maker/vehicle_class_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(WidgetRef ref) {
  final authState = ref.watch(authProvider);

  final isLoggedIn = switch (authState) {
    Authenticated _ => true,
    _ => false,
  };

  final isMaker = authState is Authenticated && authState.user.role == 'maker';

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, __) =>
            DashboardScreen(onNavigate: (path) => context.go(path)),
      ),
      GoRoute(
        path: '/devices/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => DeviceDetailScreen(
          deviceId: state.pathParameters['id']!,
          onNavigate: (path) => context.go(path),
        ),
      ),
      GoRoute(
        path: '/devices/:id/stream',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            LiveStreamScreen(deviceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/maker/devices/:id/classes',
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (_, __) => isMaker ? null : '/dashboard',
        builder: (_, state) =>
            VehicleClassScreen(deviceId: state.pathParameters['id']!),
      ),
    ],
  );
}
