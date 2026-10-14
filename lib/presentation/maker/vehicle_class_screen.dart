import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vclane_client/core/constants/vehicle_classes.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/domain/entities/vehicle_class_selection.dart';
import 'package:vclane_client/presentation/providers/class_config_provider.dart';
import 'package:vclane_client/presentation/shared/widgets/error_display.dart';
import 'package:vclane_client/presentation/shared/widgets/loading_indicator.dart';

class VehicleClassScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const VehicleClassScreen({super.key, required this.deviceId});

  @override
  ConsumerState<VehicleClassScreen> createState() => _VehicleClassScreenState();
}

class _VehicleClassScreenState extends ConsumerState<VehicleClassScreen> {
  // Working copy; null until the stored config has been loaded.
  VehicleClassSelection? _draft;
  bool _saving = false;

  Future<void> _save(VehicleClassSelection selection) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(classConfigRepositoryProvider)
          .setEnabledClasses(widget.deviceId, selection);
      ref.invalidate(enabledClassesProvider(widget.deviceId));
      messenger.showSnackBar(
        const SnackBar(content: Text('Vehicle classes saved')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stored = ref.watch(enabledClassesProvider(widget.deviceId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Vehicle Classes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/devices/${widget.deviceId}'),
        ),
        elevation: 0,
      ),
      body: stored.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorDisplay(message: e.toString()),
        data: (loaded) => _buildList(_draft ??= loaded),
      ),
    );
  }

  Widget _buildList(VehicleClassSelection draft) {
    const ids = VehicleClasses.ids;
    final enabledCount = ids.where(draft.isEnabled).length;
    // Disabling every class would also stop emergency-vehicle detection.
    final canSave = !_saving && enabledCount > 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              TextButton(
                onPressed: _saving
                    ? null
                    : () => setState(() => _draft = draft.withAll(ids, true)),
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: _saving
                    ? null
                    : () => setState(() => _draft = draft.withAll(ids, false)),
                child: const Text('Clear'),
              ),
              const Spacer(),
              Text(
                '$enabledCount/${ids.length}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final id in ids)
                CheckboxListTile(
                  value: draft.isEnabled(id),
                  title: Text(id),
                  secondary: draft.isLocked(id)
                      ? const Icon(Icons.lock_outline, size: 20)
                      : null,
                  subtitle: draft.isLocked(id)
                      ? const Text('Always on: emergency priority')
                      : null,
                  onChanged: (_saving || draft.isLocked(id))
                      ? null
                      : (v) => setState(
                          () => _draft = draft.withEnabled(id, v ?? false),
                        ),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: canSave ? () => _save(draft) : null,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
