# VC-LANE — Mobile Application

Flutter mobile app for the **VC-LANE Adaptive Traffic Monitoring System**. Provides real-time traffic monitoring, live video streaming, device management, and telemetry data visualization for traffic operators.

## Quick Links

- [📖 Full Documentation](docs/vclane-docs/docs/) — architecture, screens, data flow, API reference
- [🏗️ Project Overview](docs/vclane-docs/docs/overview.md) — system description, components, tech stack
- [📱 Mobile App Guide](docs/vclane-docs/docs/mobile-app.md) — app architecture, routes, state management
- [⚙️ Edge Device Docs](docs/vclane-docs/docs/edge-device.md) — Raspberry Pi setup, AI pipeline
- [🔧 Backend API](docs/vclane-docs/docs/backend-api.md) — REST endpoints, device management
- [📡 MQTT Protocol](docs/vclane-docs/docs/mqtt-communication.md) — topics, telemetry format, TLS
- [🎥 Media Server](docs/vclane-docs/docs/media-server.md) — MediaMTX streaming setup

## Tech Stack

| | |
|---|---|
| **Framework** | Flutter (Dart ^3.12.2) |
| **State** | Riverpod |
| **Routing** | go_router |
| **Backend** | Dio (HTTP), Firebase (Auth, Firestore, RTDB, Storage) |
| **Video** | media_kit (RTSP/WebRTC) |
| **Charts** | fl_chart |

## Quick Start

```bash
git clone --recurse-submodules https://github.com/vclane/vclane-client.git
cd vclane-client
flutter pub get
flutter run
```

See the [full setup guide](docs/vclane-docs/docs/mobile-app.md#environment--setup) for Firebase configuration.

