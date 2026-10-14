import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/presentation/providers/stream_player_provider.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final String rtspUrl;
  const VideoPlayerWidget({super.key, required this.rtspUrl});

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  @override
  void initState() {
    super.initState();
    _load(widget.rtspUrl);
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rtspUrl != widget.rtspUrl) {
      _load(widget.rtspUrl);
    }
  }

  void _load(String url) {
    ref.read(streamPlayerProvider).setSource(url);
  }

  void _retry() {
    ref.read(streamPlayerProvider).retry();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(streamPlayerProvider).controller;
    final error = ref.watch(streamErrorProvider).valueOrNull;
    final playing = ref.watch(streamPlayingProvider).valueOrNull ?? false;
    final buffering = ref.watch(streamBufferingProvider).valueOrNull ?? false;
    final elapsed = ref.watch(streamElapsedProvider).valueOrNull ?? 0;

    final hasError = error != null && error.isNotEmpty;
    final showLoading = !playing && !hasError && buffering;

    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(color: AppColors.videoBackground),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Video(
              controller: controller,
              fit: BoxFit.contain,
            ),
            if (showLoading)
              Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Connecting to stream...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${elapsed}s',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      if (elapsed > 30) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh,
                              color: Colors.white70),
                          label: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            if (hasError && !playing)
              Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.videocam_off,
                          size: 40,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Stream error',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          error,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh,
                              color: Colors.white70),
                          label: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
