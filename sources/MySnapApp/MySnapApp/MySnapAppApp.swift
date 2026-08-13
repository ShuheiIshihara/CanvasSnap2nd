//
//  MySnapAppApp.swift
//  MySnapApp
//
//

import SwiftUI
import os

@main
struct MySnapAppApp: App {
    @AppStorage(SettingsKey.saveDirectory) private var saveDirectory = AppSettings.Default.saveDirectory
    @AppStorage(SettingsKey.saveDirectoryBookmark) private var saveDirectoryBookmark = Data()

    private let coordinator = ScreenshotCoordinator()

    var body: some Scene {
        Settings {
            SettingsView()
        }

        MenuBarExtra("スクリーンショット", systemImage: "camera.viewfinder") {
            Button("今すぐキャプチャ") {
                captureAndSave()
            }
            .keyboardShortcut("5", modifiers: .command)
            Divider()
            Button("設定...") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            .keyboardShortcut(",", modifiers: .command)
            Divider()
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }

    private func captureAndSave() {
        Task {
            do {
                let url = try await coordinator.captureAndSave(
                    to: saveDirectory,
                    bookmark: saveDirectoryBookmark
                )
                AppLogger.capture.info("保存完了: \(url.path, privacy: .private)")
            } catch {
                AppLogger.capture.error("キャプチャ保存エラー: \(error.localizedDescription)")
            }
        }
    }
}
