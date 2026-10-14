# VC-LANE Client — Flutter Mobile App

This is the **Flutter mobile application** for the VC-LANE Adaptive Traffic Monitoring System.

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Routing:** go_router
- **Backend Comms:** Dio (HTTP), Firebase (Auth, Firestore, Realtime DB, Storage)
- **Video:** media_kit (RTSP/WebRTC playback)
- **Charts:** fl_chart
- **Auth:** Firebase Authentication

## Architecture

Clean Architecture with three layers:

```
lib/
├── app/                        # App entry point, router config
│   ├── app.dart                # MaterialApp.router widget
│   └── router.dart             # go_router route definitions
│
├── core/                       # Shared infrastructure
│   ├── constants/              # API, Firestore, RTDB constants
│   ├── errors/                 # Error handler, failure types
│   ├── network/                # Dio client, auth interceptor
│   ├── theme/                  # Light/dark theme
│   └── utils/                  # Helpers
│
├── data/                       # Data layer
│   ├── datasources/            # Remote data sources (Firebase, HTTP API)
│   ├── models/                 # JSON-serializable DTOs
│   └── repositories/           # Repository implementations
│
├── domain/                     # Domain layer (pure Dart, no Flutter deps)
│   ├── entities/               # Immutable domain objects
│   ├── repositories/           # Abstract repository interfaces
│   └── usecases/               # Single-responsibility business logic
│
├── presentation/               # UI layer
│   ├── auth/                   # Login screen
│   ├── dashboard/              # Dashboard screen
│   ├── devices/                # Device detail screen
│   ├── profile/                # Profile screens
│   ├── providers/              # Riverpod state providers
│   ├── shared/                 # Shared/reusable widgets
│   └── stream/                 # Live stream screen
│
├── firebase_options.dart       # Generated Firebase config
└── main.dart                   # Entry point
```

### Layer Rules

- **Data** depends only on `core` and `domain` (interfaces)
- **Domain** has zero Flutter/dependency imports — pure Dart only
- **Presentation** depends on `domain` via providers; never imports `data` directly
- **Core** is cross-cutting: constants, networking, theme, error handling

## Shared Documentation (vclane-docs)

This project includes a git submodule at `docs/vclane-docs/` containing the shared **vclane-docs** repository. It holds all cross-project documentation:

- Architecture overview
- Edge device setup and AI pipeline
- Backend API reference
- MQTT communication protocol
- Video streaming setup (MediaMTX)
- Mobile app architecture

**Start with:** `docs/vclane-docs/docs/index.md`

### Setup (for a new project)

To add the shared docs submodule to another project:

```bash
git submodule add https://github.com/vclane/vclane-docs.git docs/vclane-docs
git submodule init
git commit -m "add vclane-docs submodule"
```

### Refresh (for an existing clone)

Pull the latest from the docs repo:

```bash
git submodule update --remote docs/vclane-docs
git add docs/vclane-docs
git commit -m "chore: update vclane-docs submodule"
```

### Clone with submodules

```bash
git clone --recurse-submodules <repo-url>
```

If already cloned without submodules:

```bash
git submodule update --init
```

## Key Conventions

- Follow the layered architecture pattern (UI/Data/Domain) as detailed above
- Use Riverpod providers for state management; providers live in `presentation/providers/`
- Use go_router for navigation; routes are defined in `app/router.dart`
- All API calls go through `core/network/api_client.dart` (Dio-based)
- Domain repositories are interfaces in `domain/repositories/`; implementations in `data/repositories/`
- Use cases in `domain/usecases/` are single-responsibility classes with a `call()` method
- Models in `data/models/` extend domain entities with `fromJson`/`toJson`
- Write unit tests with `package:test`, widget tests with `flutter_test`
- Test files mirror the `lib/` structure under `test/`
