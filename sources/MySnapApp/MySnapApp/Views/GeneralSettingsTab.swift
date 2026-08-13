import SwiftUI
import AppKit

struct GeneralSettingsTab: View {
    @AppStorage("saveDirectory") private var saveDirectory = FileService.defaultSaveDirectory
    @AppStorage("saveDirectoryBookmark") private var saveDirectoryBookmark = Data()
    @AppStorage("imageFormat") private var imageFormat = "PNG"
    @AppStorage("jpegQuality") private var jpegQuality = 85.0
    @AppStorage("fileNamePattern") private var fileNamePattern = "Screenshot_{date}_{time}"
    @AppStorage("showInMenuBar") private var showInMenuBar = true
    @AppStorage("appLanguage") private var appLanguage = "system"

    var body: some View {
        Form {
            
            Section("保存設定") {
                LabeledContent("保存先ディレクトリ") {
                    HStack {
                        TextField("", text: $saveDirectory)
                        Button("参照...") { chooseSaveDirectory() }
                    }
                }
                Picker("デフォルト保存形式", selection: $imageFormat) {
                    Text("PNG").tag("PNG")
                    Text("JPEG").tag("JPEG")
                }
                LabeledContent("JPEG品質") {
                    HStack() {
                        Slider(value: $jpegQuality, in: 1...100, step: 1)
                        Text("\(Int(jpegQuality))%")
                    }
                }
                Picker("ファイル名パターン", selection: $fileNamePattern) {
                    Text("Screenshot_{date}_{time}").tag("Screenshot_{date}_{time}")
                }
            }
            
            Section("アプリ動作") {
                Toggle("メニューバーに表示", isOn: $showInMenuBar)
                Picker("表示言語", selection: $appLanguage) {
                    Text("システム設定に従う").tag("system")
                    Text("日本語").tag("ja")
                    Text("English").tag("en")
                }
            }
        }
        .formStyle(.grouped)
    }

    private func chooseSaveDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "選択"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            saveDirectoryBookmark = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            saveDirectory = url.path
        } catch {
            print("ブックマーク作成エラー: \(error)")
        }
    }
}

#Preview {
    GeneralSettingsTab()
        .frame(width: 560)
}
