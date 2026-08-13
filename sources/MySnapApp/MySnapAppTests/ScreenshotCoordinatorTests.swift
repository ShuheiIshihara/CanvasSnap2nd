//
//  ScreenshotCoordinatorTests.swift
//  MySnapAppTests
//

import XCTest
@testable import MySnapApp

final class ScreenshotCoordinatorTests: XCTestCase {

    private let expectedURL = URL(fileURLWithPath: "/tmp/Screenshot_20260101_000000.png")

    // MARK: - 成功パス

    func testCaptureAndSave_onSuccess_returnsSavedURL() async throws {
        let capturer = FakeCapturer(result: .success(try makeTestImage()))
        let saver = FakeSaver(result: .success(expectedURL))
        let sut = ScreenshotCoordinator(capturer: capturer, saver: saver)

        let url = try await sut.captureAndSave(to: "/tmp/dir")

        XCTAssertEqual(url, expectedURL)
        XCTAssertEqual(capturer.log.callCount, 1)
        XCTAssertEqual(saver.log.callCount, 1)
    }

    func testCaptureAndSave_passesDirectoryAndBookmarkToSaver() async throws {
        let capturer = FakeCapturer(result: .success(try makeTestImage()))
        let saver = FakeSaver(result: .success(expectedURL))
        let sut = ScreenshotCoordinator(capturer: capturer, saver: saver)
        let bookmark = Data([0xAA, 0xBB])

        _ = try await sut.captureAndSave(to: "/tmp/dir", bookmark: bookmark)

        XCTAssertEqual(saver.log.receivedDirectory, "/tmp/dir")
        XCTAssertEqual(saver.log.receivedBookmark, bookmark)
    }

    func testCaptureAndSave_passesCapturedImageToSaver() async throws {
        let image = try makeTestImage(width: 12, height: 5)
        let capturer = FakeCapturer(result: .success(image))
        let saver = FakeSaver(result: .success(expectedURL))
        let sut = ScreenshotCoordinator(capturer: capturer, saver: saver)

        _ = try await sut.captureAndSave(to: "/tmp/dir")

        XCTAssertEqual(saver.log.receivedImage?.width, 12)
        XCTAssertEqual(saver.log.receivedImage?.height, 5)
    }

    func testCaptureAndSave_withoutBookmark_passesNil() async throws {
        let capturer = FakeCapturer(result: .success(try makeTestImage()))
        let saver = FakeSaver(result: .success(expectedURL))
        let sut = ScreenshotCoordinator(capturer: capturer, saver: saver)

        _ = try await sut.captureAndSave(to: "/tmp/dir")

        XCTAssertEqual(saver.log.receivedBookmark, Data?.none)
    }

    // MARK: - エラーパス

    func testCaptureAndSave_whenCaptureFails_rethrowsAndSkipsSave() async throws {
        let capturer = FakeCapturer(result: .failure(TestError.capture))
        let saver = FakeSaver(result: .success(expectedURL))
        let sut = ScreenshotCoordinator(capturer: capturer, saver: saver)

        do {
            _ = try await sut.captureAndSave(to: "/tmp/dir")
            XCTFail("エラーが投げられるべき")
        } catch {
            XCTAssertEqual(error as? TestError, .capture)
        }
        // キャプチャに失敗した時点で保存は呼ばれない
        XCTAssertEqual(saver.log.callCount, 0)
    }

    func testCaptureAndSave_whenSaveFails_rethrowsSaveError() async throws {
        let capturer = FakeCapturer(result: .success(try makeTestImage()))
        let saver = FakeSaver(result: .failure(TestError.save))
        let sut = ScreenshotCoordinator(capturer: capturer, saver: saver)

        do {
            _ = try await sut.captureAndSave(to: "/tmp/dir")
            XCTFail("エラーが投げられるべき")
        } catch {
            XCTAssertEqual(error as? TestError, .save)
        }
        XCTAssertEqual(capturer.log.callCount, 1)
    }

    func testCaptureAndSave_propagatesCaptureServiceErrorCases() async throws {
        for expected in [CaptureService.CaptureError.noDisplayFound, .captureFailure] {
            let capturer = FakeCapturer(result: .failure(expected))
            let sut = ScreenshotCoordinator(
                capturer: capturer,
                saver: FakeSaver(result: .success(expectedURL))
            )

            do {
                _ = try await sut.captureAndSave(to: "/tmp/dir")
                XCTFail("エラーが投げられるべき: \(expected)")
            } catch let error as CaptureService.CaptureError {
                XCTAssertEqual(error, expected)
            }
        }
    }

    // MARK: - 実際の FileService と組み合わせた結合テスト

    func testCaptureAndSave_withRealFileService_writesFile() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CoordinatorTests-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }

        let sut = ScreenshotCoordinator(
            capturer: FakeCapturer(result: .success(try makeTestImage(width: 2, height: 2))),
            saver: FileService()
        )

        let url = try await sut.captureAndSave(to: directory.path)

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }
}
