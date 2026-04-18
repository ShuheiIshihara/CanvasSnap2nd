//
//  MySnapAppApp.swift
//  MySnapApp
//
//  Created by 石原脩平 on 2026/04/16.
//

import SwiftUI

@main
struct MySnapAppApp: App {
    var body: some Scene {
        Settings {
            SettingsView()
        }

        MenuBarExtra("スクリーンショット", systemImage: "camera.viewfinder") {
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
}
