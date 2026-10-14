---
name: reference-docs
description: Load project documentation from the shared vclane-docs submodule. Use when you need architectural guidance, API specs, streaming setup, or any cross-project knowledge.
---

# Project Documentation

This project uses a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) pointing to the shared **vclane-docs** repository at `docs/vclane-docs/`.

## Accessing Docs

All documentation lives under `docs/vclane-docs/docs/`. The entry point is `docs/vclane-docs/docs/index.md`.

Key documents:

| File | Covers |
|---|---|
| `overview.md` | System overview, components, tech stack |
| `architecture.md` | System architecture, data flow |
| `edge-device.md` | Raspberry Pi edge device setup and logic |
| `backend-api.md` | Backend REST API, endpoints |
| `mqtt-communication.md` | MQTT topics, message format, TLS |
| `media-server.md` | MediaMTX streaming setup |
| `mobile-app.md` | Flutter mobile app specifics |

## Setup (for a new project that doesn't have the submodule yet)

```bash
git submodule add https://github.com/vclane/vclane-docs.git docs/vclane-docs
git submodule init
git commit -m "add vclane-docs submodule"
```

## Refresh (for an existing clone, pull latest docs)

```bash
git submodule update --remote docs/vclane-docs
git add docs/vclane-docs
git commit -m "chore: update vclane-docs submodule"
```

## Clone with submodules

```bash
git clone --recurse-submodules <repo-url>
```

If already cloned without submodules:

```bash
git submodule update --init
```
