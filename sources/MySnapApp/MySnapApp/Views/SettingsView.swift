import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label("一般", systemImage: "gearshape")
                }
            HotkeySettingsTab()
                .tabItem {
                    Label("ホットキー", systemImage: "keyboard")
                }
            CaptureSettingsTab()
                .tabItem {
                    Label("キャプチャ", systemImage: "camera")
                }
        }
        .frame(width: 560)
    }
}

#Preview {
    SettingsView()
}
