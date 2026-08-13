import Foundation
import CoreGraphics

/// 画像保存の抽象。テストではフェイク実装に差し替える。
protocol ImageSaving {
    func save(_ image: CGImage, to directory: String, bookmark: Data?) throws -> URL
}

extension FileService: ImageSaving {}
