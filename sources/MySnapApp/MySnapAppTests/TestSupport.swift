//
//  TestSupport.swift
//  MySnapAppTests
//

import XCTest
import CoreGraphics
@testable import MySnapApp

/// テスト用のダミー画像を生成する（テスト環境では実際のキャプチャを行えないため）
func makeTestImage(width: Int = 1, height: Int = 1) throws -> CGImage {
    let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )
    return try XCTUnwrap(context?.makeImage(), "テスト用CGImageの生成に失敗した")
}

/// テスト用のエラー
enum TestError: Error, Equatable {
    case capture
    case save
}

/// ScreenCapturing のフェイク実装
struct FakeCapturer: ScreenCapturing {
    var result: Result<CGImage, Error>
    /// 呼び出し回数を記録する
    final class Log: @unchecked Sendable {
        var callCount = 0
    }
    let log = Log()

    func captureFullScreen() async throws -> CGImage {
        log.callCount += 1
        return try result.get()
    }
}

/// ImageSaving のフェイク実装
struct FakeSaver: ImageSaving {
    var result: Result<URL, Error>

    final class Log: @unchecked Sendable {
        var callCount = 0
        var receivedImage: CGImage?
        var receivedDirectory: String?
        var receivedBookmark: Data??
    }
    let log = Log()

    func save(_ image: CGImage, to directory: String, bookmark: Data?) throws -> URL {
        log.callCount += 1
        log.receivedImage = image
        log.receivedDirectory = directory
        log.receivedBookmark = bookmark
        return try result.get()
    }
}
