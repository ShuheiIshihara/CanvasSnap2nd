import Foundation
import CoreGraphics
import ScreenCaptureKit

struct CaptureService {

    enum CaptureError: Error {
        case noDisplayFound
        case captureFailure
    }

    func captureFullScreen() async throws -> CGImage {
        
        // 利用可能なディスプレイ一覧を取得
        let shareableContent = try await SCShareableContent.current
        
        
        guard let display = shareableContent.displays.first else {
            throw CaptureError.noDisplayFound
        }
        
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = SCStreamConfiguration()
        
        let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
        
        return image
    }
}
