//
//  FileServiceTests.swift
//  MySnapAppTests
//

import XCTest
import CoreGraphics
import ImageIO
@testable import MySnapApp

final class FileServiceTests: XCTestCase {

    private var sut: FileService!
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = FileService()
        // テストごとに独立したテンポラリディレクトリを用意し、実際の保存先には一切触れない
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("FileServiceTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        tempDirectory = nil
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - 正常系: 保存先

    func testSave_returnsURLInsideGivenDirectory() throws {
        let image = try makeTestImage()

        let url = try sut.save(image, to: tempDirectory.path)

        XCTAssertEqual(
            url.deletingLastPathComponent().standardizedFileURL.path,
            tempDirectory.standardizedFileURL.path
        )
    }

    func testSave_whenDirectoryDoesNotExist_createsIt() throws {
        let image = try makeTestImage()
        let nestedDirectory = tempDirectory.appendingPathComponent("nested/deep")
        XCTAssertFalse(FileManager.default.fileExists(atPath: nestedDirectory.path))

        let url = try sut.save(image, to: nestedDirectory.path)

        var isDirectory: ObjCBool = false
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: nestedDirectory.path, isDirectory: &isDirectory)
        )
        XCTAssertTrue(isDirectory.boolValue)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    // MARK: - 正常系: 書き出したファイル

    func testSave_createsPNGFileOnDisk() throws {
        let image = try makeTestImage(width: 4, height: 4)

        let url = try sut.save(image, to: tempDirectory.path)

        let data = try Data(contentsOf: url)
        // PNGシグネチャ: 89 50 4E 47 0D 0A 1A 0A
        let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        XCTAssertGreaterThan(data.count, pngSignature.count)
        XCTAssertEqual(Array(data.prefix(pngSignature.count)), pngSignature)
    }

    func testSave_writtenImageKeepsOriginalPixelSize() throws {
        let image = try makeTestImage(width: 7, height: 3)

        let url = try sut.save(image, to: tempDirectory.path)

        let source = try XCTUnwrap(CGImageSourceCreateWithURL(url as CFURL, nil))
        let written = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
        XCTAssertEqual(written.width, 7)
        XCTAssertEqual(written.height, 3)
    }

    // MARK: - 正常系: ファイル名

    func testSave_fileNameFollowsScreenshotPattern() throws {
        let image = try makeTestImage()

        let url = try sut.save(image, to: tempDirectory.path)

        let fileName = url.lastPathComponent
        let pattern = #"^Screenshot_\d{8}_\d{6}\.png$"#
        XCTAssertNotNil(
            fileName.range(of: pattern, options: .regularExpression),
            "想定外のファイル名: \(fileName)"
        )
    }

    /// 現状のファイル名は秒精度のため、同一秒内の連続保存は同じファイルを上書きする。
    /// 連番付与を実装する際はこのテストを更新すること。
    func testSave_twiceWithinSameSecond_overwritesSameFile() throws {
        let image = try makeTestImage()

        let first = try sut.save(image, to: tempDirectory.path)
        let second = try sut.save(image, to: tempDirectory.path)

        let contents = try FileManager.default.contentsOfDirectory(atPath: tempDirectory.path)
        if first.lastPathComponent == second.lastPathComponent {
            XCTAssertEqual(contents.count, 1, "同名保存なのにファイルが複数存在する")
        } else {
            // 秒をまたいだ場合は別ファイルになる
            XCTAssertEqual(contents.count, 2)
        }
    }

    // MARK: - 異常系

    func testSave_whenDirectoryCannotBeCreated_throws() throws {
        let image = try makeTestImage()
        // /dev/null は通常ファイルなので、その配下にはディレクトリを作成できない
        let impossibleDirectory = "/dev/null/MySnapApp"

        XCTAssertThrowsError(try sut.save(image, to: impossibleDirectory)) { error in
            XCTAssertTrue(
                error is CocoaError,
                "ディレクトリ作成の失敗がそのまま伝播すること: \(error)"
            )
        }
    }

    func testSave_whenParentDirectoryIsNotWritable_throws() throws {
        let image = try makeTestImage()
        let readOnlyParent = tempDirectory.appendingPathComponent("readonly")
        try FileManager.default.createDirectory(at: readOnlyParent, withIntermediateDirectories: true)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o500],
            ofItemAtPath: readOnlyParent.path
        )
        // tearDown で削除できるよう権限を戻す
        addTeardownBlock {
            try? FileManager.default.setAttributes(
                [.posixPermissions: 0o700],
                ofItemAtPath: readOnlyParent.path
            )
        }

        XCTAssertThrowsError(
            try sut.save(image, to: readOnlyParent.appendingPathComponent("child").path)
        )
    }

    func testSave_toExistingFilePathAsDirectory_throws() throws {
        let image = try makeTestImage()
        let filePath = tempDirectory.appendingPathComponent("not-a-directory")
        try Data([0x00]).write(to: filePath)

        // 保存先としてファイルを指定した場合、ディレクトリ作成に失敗する
        XCTAssertThrowsError(try sut.save(image, to: filePath.path))
    }

    // MARK: - 境界値

    func testSave_withMinimumSizeImage_succeeds() throws {
        let image = try makeTestImage(width: 1, height: 1)

        let url = try sut.save(image, to: tempDirectory.path)

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testSave_withTrailingSlashInDirectory_savesToSameDirectory() throws {
        let image = try makeTestImage()

        let url = try sut.save(image, to: tempDirectory.path + "/")

        XCTAssertEqual(
            url.deletingLastPathComponent().standardizedFileURL.path,
            tempDirectory.standardizedFileURL.path
        )
    }

    // MARK: - 境界値: bookmark 引数

    func testSave_withNilBookmark_succeeds() throws {
        let image = try makeTestImage()

        let url = try sut.save(image, to: tempDirectory.path, bookmark: nil)

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testSave_withEmptyBookmark_succeeds() throws {
        let image = try makeTestImage()

        let url = try sut.save(image, to: tempDirectory.path, bookmark: Data())

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testSave_withInvalidBookmark_stillSavesFile() throws {
        let image = try makeTestImage()
        let invalidBookmark = Data([0x00, 0x01, 0x02, 0x03])

        // 壊れたブックマークは解決に失敗するだけで、保存処理自体は継続される
        let url = try sut.save(image, to: tempDirectory.path, bookmark: invalidBookmark)

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    // MARK: - defaultSaveDirectory

    func testDefaultSaveDirectory_isAbsolutePathUnderPictures() {
        let path = FileService.defaultSaveDirectory
        let url = URL(fileURLWithPath: path)

        XCTAssertTrue(path.hasPrefix("/"), "絶対パスであること: \(path)")
        XCTAssertEqual(url.lastPathComponent, "MySnapApp")
        XCTAssertEqual(url.deletingLastPathComponent().lastPathComponent, "Pictures")
    }

    func testDefaultSaveDirectory_isStableAcrossCalls() {
        XCTAssertEqual(FileService.defaultSaveDirectory, FileService.defaultSaveDirectory)
    }
}
