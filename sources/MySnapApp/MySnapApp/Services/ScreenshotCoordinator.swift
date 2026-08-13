import Foundation
import CoreGraphics

/// キャプチャ → 保存の一連の流れを組み立てる。
/// OS依存の処理は ScreenCapturing / ImageSaving の裏に隠れているため、この型はテスト可能。
struct ScreenshotCoordinator {

    private let capturer: ScreenCapturing
    private let saver: ImageSaving

    init(capturer: ScreenCapturing = CaptureService(), saver: ImageSaving = FileService()) {
        self.capturer = capturer
        self.saver = saver
    }

    /// 全画面をキャプチャして保存し、保存先URLを返す。
    /// キャプチャ・保存のどちらで失敗しても、その元のエラーをそのまま投げる。
    @discardableResult
    func captureAndSave(to directory: String, bookmark: Data? = nil) async throws -> URL {
        let image = try await capturer.captureFullScreen()
        return try saver.save(image, to: directory, bookmark: bookmark)
    }
}
