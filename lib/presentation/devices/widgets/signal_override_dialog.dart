import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/presentation/providers/device_provider.dart';

class SignalOverrideDialog extends ConsumerStatefulWidget {
  final String deviceId;
  final String? groupId;
  final String targetSignal;

  const SignalOverrideDialog({
    super.key,
    required this.deviceId,
    this.groupId,
    required this.targetSignal,
  });

  @override
  ConsumerState<SignalOverrideDialog> createState() => _SignalOverrideDialogState();
}

class _SignalOverrideDialogState extends ConsumerState<SignalOverrideDialog> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isIndefinite = false;
  final _durationController = TextEditingController(text: '60');

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicesByGroup = ref.watch(devicesByGroupProvider);
    final groupDevices = widget.groupId != null ? devicesByGroup[widget.groupId] ?? [] : [];
    final affectedCount = groupDevices.length;

    final (Color signalColor, IconData signalIcon) = switch (widget.targetSignal
        .toUpperCase()) {
      'GREEN' => (AppColors.online, Icons.check_circle),
      'YELLOW' => (AppColors.warning, Icons.warning),
      'RED' => (AppColors.offline, Icons.stop_circle),
      _ => (AppColors.primary, Icons.help_outline),
    };

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Override Signal',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(signalIcon, color: signalColor, size: 32),
              const SizedBox(width: 10),
              Text(
                widget.targetSignal.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: signalColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _durationController,
                  enabled: !_isIndefinite,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Duration (minutes)',
                    hintText: '60',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: _isIndefinite,
                onChanged: (v) => setState(() => _isIndefinite = v ?? false),
              ),
              const Text('Indefinite', style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            affectedCount > 1
                ? 'This will affect all $affectedCount junctions in the same group.'
                : 'No group members — override applies to this junction only.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.offline),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: signalColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isLoading ? null : _handleConfirm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }

  Future<void> _handleConfirm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final int? durationSeconds;
      if (_isIndefinite) {
        durationSeconds = 0;
      } else {
        final minutes = int.tryParse(_durationController.text);
        if (minutes == null || minutes <= 0) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Please enter a valid duration.';
          });
          return;
        }
        durationSeconds = minutes * 60;
      }

      await ref
          .read(overrideSignalUseCaseProvider)
          .execute(widget.deviceId, widget.targetSignal, durationSeconds: durationSeconds);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to override signal. Please try again.';
        });
      }
    }
  }
}
