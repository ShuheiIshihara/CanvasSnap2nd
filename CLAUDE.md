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

## Architecture

- `sources/MySnapApp/MySnapApp/` — app target
  - `MySnapAppApp.swift` — app entry point
  - `ContentView.swift` — root view
  - `Services/` — capture and file I/O logic (`CaptureService.swift` wraps ScreenCaptureKit, `FileService.swift` handles saving output)
  - `Views/` — SwiftUI views, currently the settings UI (`SettingsView.swift` plus `GeneralSettingsTab.swift`, `CaptureSettingsTab.swift`, `HotkeySettingsTab.swift`)
- `sources/MySnapApp/MySnapAppTests/` — unit tests
- `sources/MySnapApp/MySnapAppUITests/` — UI tests
- Core Data was removed in favor of a simpler settings-driven approach (see commit history around Phase 1 UI work).

## tech-term-explainer
  tech_term_output: docs/terms/
