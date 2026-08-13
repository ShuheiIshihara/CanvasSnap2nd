import CoreGraphics

/// 画面キャプチャの抽象。テストではフェイク実装に差し替える。
protocol ScreenCapturing {
    func captureFullScreen() async throws -> CGImage
}

extension CaptureService: ScreenCapturing {}
