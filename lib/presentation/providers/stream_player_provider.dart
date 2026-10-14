import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:vclane_client/core/constants/stream_constants.dart';

/// Owns a single [Player] + [VideoController] for the live stream screen.
/// Disposed automatically when the stream screen is popped (autoDispose).
class StreamPlayer {
  StreamPlayer() {
    player = Player();
    controller = VideoController(player);
  }

  late final Player player;
  late final VideoController controller;

  String? _loadedUrl;
  DateTime? connectingSince;

  Future<void> setSource(String url) async {
    if (url.isEmpty) return;
    _loadedUrl = url;
    connectingSince = DateTime.now();
    await player.open(
      Media(url, extras: {'rtsp-transport': StreamConstants.rtspTransport}),
      play: true,
    );
  }

  Future<void> retry() async {
    final url = _loadedUrl;
    if (url == null || url.isEmpty) return;
    connectingSince = DateTime.now();
    await player.open(
      Media(url, extras: {'rtsp-transport': StreamConstants.rtspTransport}),
      play: true,
    );
  }

  void play() => player.play();
  void pause() => player.pause();
  void togglePlay() => player.playOrPause();

  void dispose() => player.dispose();
}

final streamPlayerProvider = Provider.autoDispose<StreamPlayer>((ref) {
  final streamPlayer = StreamPlayer();
  ref.onDispose(streamPlayer.dispose);
  return streamPlayer;
});

/// Latest player error (e.g. RTSP connection failure), for overlay display.
final streamErrorProvider = StreamProvider.autoDispose<String>((ref) {
  final player = ref.watch(streamPlayerProvider).player;
  return player.stream.error;
});

/// Whether the player is currently playing, used to hide the error overlay
/// once the stream goes live (so transient errors don't cover the feed).
final streamPlayingProvider = StreamProvider.autoDispose<bool>((ref) {
  final player = ref.watch(streamPlayerProvider).player;
  return player.stream.playing;
});

/// Whether the player is currently buffering (connecting or loading data).
final streamBufferingProvider = StreamProvider.autoDispose<bool>((ref) {
  final player = ref.watch(streamPlayerProvider).player;
  return player.stream.buffering;
});

/// Emits elapsed seconds since the stream started connecting.
final streamElapsedProvider = StreamProvider.autoDispose<int>((ref) {
  final player = ref.watch(streamPlayerProvider);
  final since = player.connectingSince;
  if (since == null) return Stream.value(0);

  final controller = StreamController<int>();
  int elapsed = 0;
  controller.add(0);

  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    elapsed = DateTime.now().difference(since).inSeconds;
    controller.add(elapsed);
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
