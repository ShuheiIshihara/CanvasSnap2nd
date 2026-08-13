//
//  MySnapAppApp.swift
//  MySnapApp
//
//  Created by 石原脩平 on 2026/04/16.
//

import SwiftUI

@main
struct MySnapAppApp: App {
    @AppStorage("saveDirectory") private var saveDirectory = "~/Desktop/Screenshots"

    private let captureService = CaptureService()
    private let fileService = FileService()

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
                let image = try await captureService.captureFullScreen()
                let url = try fileService.save(image, to: saveDirectory)
                print("保存完了: \(url.path)")
            } catch {
                print("エラー: \(error)")
            }
        }
    }
}
