class StreamConstants {
  StreamConstants._();

  /// Dev/test fallback RTSP URL used only when a device's `rtspUrl` is empty.
  static const String sampleRtspUrl =
      'rtsp://cam-tb-001:vcl-76cf69e1f6a23d0c06bfc29f9c716db1@vclane.devistlab.com:8554/cam-tb-001';

  /// RTSP transport protocol. `tcp` is required for playback on the Android
  /// emulator; `udp` (default) is often dropped by the emulator's network stack.
  static const String rtspTransport = 'tcp';
}
