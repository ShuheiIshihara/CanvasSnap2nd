# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CanvasSnap2nd** is a macOS screenshot capture app, built with Swift 6 + SwiftUI/AppKit on top of ScreenCaptureKit. The project was originally planned as a C# + Avalonia app but switched to native Swift for direct access to ScreenCaptureKit and macOS-specific features (global hotkeys, menu bar residency). Target OS is macOS 26 (Apple Silicon / arm64). Requirements live in `docs/memo/要件定義書_スクリーンショットアプリ.md`.

## Git Workflow

- Default branch: `main`
- Active development branch: `develop`
- Commit messages must be in Japanese (see global CLAUDE.md rules)

## Build & Test Commands

The Xcode project is at `sources/MySnapApp/MySnapApp.xcodeproj` (scheme: `MySnapApp`).

```bash
# Build
xcodebuild -project sources/MySnapApp/MySnapApp.xcodeproj -scheme MySnapApp build

# Run all tests
xcodebuild -project sources/MySnapApp/MySnapApp.xcodeproj -scheme MySnapApp test

# Run a single test
xcodebuild -project sources/MySnapApp/MySnapApp.xcodeproj -scheme MySnapApp test \
  -only-testing:MySnapAppTests/SomeTestClass/testSomeMethod
```

Prefer opening the project in Xcode for iterative development; use `xcodebuild` from the CLI for verification.

## Testing Policy

**Every feature must ship with tests.** When adding or changing a feature, write or update its tests in the same change — a feature is not done until its tests exist and pass.

- Test target: `sources/MySnapApp/MySnapAppTests/`, one test file per production type (`FileService.swift` → `FileServiceTests.swift`).
- Framework: XCTest (`@testable import MySnapApp`). Use `async` test methods for async APIs.
- Naming: `test<MethodName>_<condition>_<expectedResult>` (e.g. `testSave_whenDirectoryMissing_createsDirectory`).
- Pure logic (path building, file name generation, settings defaults) must be unit-tested.
- Isolation: no writes outside `FileManager.default.temporaryDirectory`; clean up created files in `tearDown`. Never depend on the user's real save directory or on `UserDefaults` standard state — inject a test suite name or temporary directory instead.
- System-dependent code (ScreenCaptureKit capture, screen-recording permission, `NSOpenPanel`) cannot run headless: extract the testable logic behind a protocol and test against a fake; leave the thin OS-calling wrapper untested rather than writing flaky tests.
- UI tests in `MySnapAppUITests/` are for launch and end-to-end settings flows only; keep logic coverage in unit tests.
- Run tests before every commit:
  `xcodebuild -project sources/MySnapApp/MySnapApp.xcodeproj -scheme MySnapApp test`

### Required test categories

Every feature needs all three categories below. If a category genuinely does not apply, say so explicitly in a comment on the test class rather than silently omitting it. Group them with `// MARK: -` headers so gaps are visible in review.

1. **正常系 (happy path)** — the feature used as intended produces the expected result. Assert the actual output (returned value, file written, state changed), never just "it did not throw".
2. **異常系 (error path)** — one test per `throw` site and per failure the caller can trigger: missing resource, permission denied, invalid or corrupt input, dependency failure. Assert the specific error case, and assert that later steps were skipped (e.g. capture fails → save is never called).
3. **境界値 (boundary values)** — the edges of every accepted range or size: minimum, maximum, just outside both ends, zero/empty, and `nil` vs. empty (`Data()`, `""`). For numeric settings, test that out-of-range stored values are clamped on read, not just on write.

Also pin current behavior you intend to change later: write the test against what the code does today with a comment explaining the intended future change (see `testSave_twiceWithinSameSecond_overwritesSameFile`).

## Architecture

- `sources/MySnapApp/MySnapApp/` — app target
  - `MySnapAppApp.swift` — app entry point
  - `ContentView.swift` — root view
  - `Services/`
    - `CaptureService.swift` — wraps ScreenCaptureKit; conforms to the `ScreenCapturing` protocol
    - `FileService.swift` — writes the PNG to disk; conforms to the `ImageSaving` protocol
    - `ScreenCapturing.swift` / `ImageSaving.swift` — protocols that let tests substitute fakes for the OS-dependent services
    - `ScreenshotCoordinator.swift` — orchestrates capture → save; the app entry point calls this, not the services directly
    - `AppSettings.swift` — `SettingsKey` constants, default values, and a `UserDefaults`-injectable accessor. Views bind via `@AppStorage(SettingsKey.x)` with `AppSettings.Default.x`; never hard-code a key or default in a view.
  - `Views/` — SwiftUI views, currently the settings UI (`SettingsView.swift` plus `GeneralSettingsTab.swift`, `CaptureSettingsTab.swift`, `HotkeySettingsTab.swift`)
- `sources/MySnapApp/MySnapAppTests/` — unit tests
- `sources/MySnapApp/MySnapAppUITests/` — UI tests
- Core Data was removed in favor of a simpler settings-driven approach (see commit history around Phase 1 UI work).

## tech-term-explainer
  tech_term_output: docs/terms/
