import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vclane_client/domain/entities/device.dart';
import 'package:vclane_client/domain/entities/group.dart';
import 'package:vclane_client/domain/entities/telemetry.dart';
import 'package:vclane_client/data/datasources/device_remote_datasource.dart';
import 'package:vclane_client/data/datasources/group_remote_datasource.dart';
import 'package:vclane_client/data/datasources/signal_override_remote_datasource.dart';
import 'package:vclane_client/data/repositories/device_repository_impl.dart';
import 'package:vclane_client/data/repositories/group_repository_impl.dart';
import 'package:vclane_client/domain/repositories/device_repository.dart';
import 'package:vclane_client/domain/repositories/group_repository.dart';
import 'package:vclane_client/domain/usecases/override_signal_usecase.dart';
import 'package:vclane_client/core/network/api_client.dart';
import 'package:vclane_client/core/network/auth_interceptor.dart';
import 'package:vclane_client/presentation/providers/telemetry_provider.dart';

// ── Network ──

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(authInterceptor: ref.watch(authInterceptorProvider));
});

// ── Device ──

final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>((ref) {
  return DeviceRemoteDataSource(FirebaseFirestore.instance);
});

final signalOverrideDataSourceProvider = Provider<SignalOverrideRemoteDataSource>((ref) {
  return SignalOverrideRemoteDataSource(ref.watch(apiClientProvider));
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(
    ref.watch(deviceRemoteDataSourceProvider),
    ref.watch(telemetryDataSourceProvider),
    ref.watch(signalOverrideDataSourceProvider),
  );
});

final overrideSignalUseCaseProvider = Provider<OverrideSignalUseCase>((ref) {
  return OverrideSignalUseCase(ref.watch(deviceRepositoryProvider));
});

final deviceListProvider = StreamProvider<List<Device>>((ref) {
  return ref.watch(deviceRepositoryProvider).watchDevices();
});

final deviceProvider = StreamProvider.family<Device?, String>((ref, id) {
  return ref.watch(deviceRepositoryProvider).watchDevice(id);
});

// ── Group ──

final groupRemoteDataSourceProvider = Provider<GroupRemoteDataSource>((ref) {
  return GroupRemoteDataSource(FirebaseFirestore.instance);
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(ref.watch(groupRemoteDataSourceProvider));
});

final groupListProvider = StreamProvider<List<Group>>((ref) {
  return ref.watch(groupRepositoryProvider).watchGroups();
});

final groupProvider = StreamProvider.family<Group?, String>((ref, id) {
  return ref.watch(groupRepositoryProvider).watchGroup(id);
});

// ── Grouped devices ──

final devicesByGroupProvider = Provider<Map<String?, List<Device>>>((ref) {
  final devices = ref.watch(deviceListProvider).valueOrNull ?? [];
  final map = <String?, List<Device>>{};
  for (final d in devices) {
    map.putIfAbsent(d.groupId, () => []).add(d);
  }
  return map;
});

// ── Effective telemetry (overridden signal wins) ──

final effectiveReadingProvider = Provider.family<Telemetry?, String>((
  ref,
  deviceId,
) {
  final reading = ref.watch(telemetryProvider(deviceId)).valueOrNull;
  return reading;
});
