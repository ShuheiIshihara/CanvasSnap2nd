import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct FileService {

    enum FileServiceError: Error {
          case failedToSave
      }

    /// サンドボックス環境でも書き込み可能な、コンテナ内Picturesディレクトリの絶対パスをデフォルト保存先とする
    static var defaultSaveDirectory: String {
        let picturesURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Pictures")
        return picturesURL.appendingPathComponent("MySnapApp").path
    }

    func save(_ image: CGImage, to directory: String, bookmark: Data? = nil) throws -> URL {

        // 1. ファイル名を生成する（例: "Screenshot_20260419_143052.png"）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "Screenshot_\(dateFormatter.string(from: Date())).png"

        // 2. 保存先URLを組み立てる
        let url = URL(fileURLWithPath: (directory as NSString).expandingTildeInPath).appendingPathComponent(fileName)

        // 3. ユーザーが「参照...」で選んだフォルダの場合、セキュリティスコープ付きブックマークでアクセス権を復元する
        var accessedURL: URL?
        if let bookmark, !bookmark.isEmpty {
            var isStale = false
            if let bookmarkedURL = try? URL(
                resolvingBookmarkData: bookmark,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            ), bookmarkedURL.startAccessingSecurityScopedResource() {
                accessedURL = bookmarkedURL
            }
        }
        defer { accessedURL?.stopAccessingSecurityScopedResource() }

        // 4. 保存先ディレクトリがなければ作成する
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        // 5. CGImage を PNG として書き出す
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw FileServiceError.failedToSave
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw FileServiceError.failedToSave
        }

        return url
    }
}
