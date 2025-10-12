# TIM Nexus Architecture

TIM Nexus is a production-grade showcase app that demonstrates how to integrate the `tim` SDK inside a polished Flutter experience. The goal is to give developers, designers, and product teams an end-to-end reference for permissions, device setup, waveform editing, and telemetry.

## High-Level Flow
- **Launch & Permissions**
  - Dark, tech-styled landing screen explains the experience and guides users through granting Bluetooth, Location (Android), and Notifications permissions.
  - Permission orchestration handled by a dedicated `PermissionsCoordinator` with platform-aware copy and graceful fallbacks.
- **Device Discovery**
  - Real-time scan dashboard visualises nearby TIM-compatible devices using `TimService.scan`.
  - Uses animated cards that surface signal strength, battery, and firmware information once available.
- **Connection Pipeline**
  - Unified `DeviceSessionController` abstracts connection lifecycle, retries, and state broadcasting.
  - Connection progress presented with futuristic progress visuals and actionable error messaging.
- **Waveform Studio**
  - Interactive editor lets users sculpt vibration patterns on a timeline.
  - Generates PWM sequences which are streamed to `TimDevice.writeMotor`.
  - Includes curated presets for quick testing plus manual sculpting for power users.
- **Live Telemetry**
  - Battery, RSSI, and task logs visualised in real time.
  - Uses streaming widgets that subscribe to `TimDevice` controllers.

## Project Structure
```
lib/
  main.dart                  # bootstrap + dependency injection
  app.dart                   # MaterialApp + routes + theme
  core/
    theme/                   # Dark tech theme, text styles, gradients
    routing/                 # Router + navigation helpers
    permissions/             # Platform-specific permission handling
    services/                # Wrappers for TimService, logging, analytics stubs
  features/
    onboarding/              # Intro screens, permission education
    scanner/                 # Device discovery UI and logic
    session/                 # Connection state machines, device detail view
    wave_editor/             # Waveform editor widgets + state
    telemetry/               # Logs, battery, RSSI visualisations
  shared/
    widgets/                 # Reusable UI components (buttons, cards, gradients)
    utils/                   # Formatters, extensions
    state/                   # Shared base classes for controllers/notifiers
```

## State Management
- Lightweight approach using `ChangeNotifier` + `ValueNotifier` for feature modules.
- Asynchronous operations (scan, connect, motor writes) wrapped in use-case classes to keep UI declarative.
- Streams from `TimDevice` bridged into `ValueNotifier`s for simple binding without heavy frameworks.

## Styling & UX
- Global dark theme with neon accent palette, custom typography, and glassmorphism-inspired surfaces.
- Motion design emphasises system feedback (scanning pulses, connection progress arcs).
- Dedicated permission microcopy with context-aware troubleshooting tips.

## Integration Points
- `tim` package consumed via local path dependency to mirror real-world integration.
- `permission_handler` used for runtime permissions.
- Optional `rive`/`lottie` slots reserved for future animated assets (stubbed for now).
- Logging piped through `TimService.logger` stream and surfaced in-app.

## Testing Strategy
- Golden tests for critical UI states (onboarding, scanner cards, wave editor).
- Integration test covering permission grant → scan → connect → motor write happy path (mocked device layer).
- Unit tests for waveform generation utilities to guarantee motor output correctness.

This blueprint keeps the codebase approachable for developers while giving designers and product stakeholders a canvas that feels production-ready.
