import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct FileService {
    
    enum FileServiceError: Error {
          case failedToSave
      }

    func save(_ image: CGImage, to directory: String) throws -> URL {
        
        // 1. ファイル名を生成する（例: "Screenshot_20260419_143052.png"）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "Screenshot_\(dateFormatter.string(from: Date())).png"
        
        // 2. 保存先URLを組み立てる
        let url = URL(fileURLWithPath: (directory as NSString).expandingTildeInPath).appendingPathComponent(fileName)

        // 3. 保存先ディレクトリがなければ作成する
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        // 4. CGImage を PNG として書き出す
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
