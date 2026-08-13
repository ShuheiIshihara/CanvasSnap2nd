//
//  AppSettingsTests.swift
//  MySnapAppTests
//

import XCTest
@testable import MySnapApp

final class AppSettingsTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!
    private var sut: AppSettings!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // 標準の UserDefaults を汚さないよう、テスト専用スイートを使う
        suiteName = "AppSettingsTests-\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        sut = AppSettings(defaults: defaults)
    }

    override func tearDownWithError() throws {
        defaults?.removePersistentDomain(forName: suiteName)
        sut = nil
        defaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    // MARK: - デフォルト値

    func testDefaults_whenNothingStored_returnDocumentedValues() {
        XCTAssertEqual(sut.imageFormat, "PNG")
        XCTAssertEqual(sut.jpegQuality, 85.0)
        XCTAssertEqual(sut.fileNamePattern, "Screenshot_{date}_{time}")
        XCTAssertTrue(sut.showInMenuBar)
        XCTAssertEqual(sut.appLanguage, "system")
        XCTAssertEqual(sut.saveDirectory, FileService.defaultSaveDirectory)
        XCTAssertNil(sut.saveDirectoryBookmark)
    }

    /// View の @AppStorage が使う初期値と AppSettings のデフォルトが一致していること
    func testDefaultConstants_matchSettingsUsedByViews() {
        XCTAssertEqual(AppSettings.Default.imageFormat, "PNG")
        XCTAssertEqual(AppSettings.Default.jpegQuality, 85.0)
        XCTAssertEqual(AppSettings.Default.fileNamePattern, "Screenshot_{date}_{time}")
        XCTAssertEqual(AppSettings.Default.appLanguage, "system")
        XCTAssertTrue(AppSettings.Default.showInMenuBar)
    }

    // MARK: - 読み書きの往復

    func testSaveDirectory_roundTrips() {
        sut.saveDirectory = "/tmp/snap"
        XCTAssertEqual(sut.saveDirectory, "/tmp/snap")
        XCTAssertEqual(defaults.string(forKey: SettingsKey.saveDirectory), "/tmp/snap")
    }

    func testImageFormat_roundTrips() {
        sut.imageFormat = "JPEG"
        XCTAssertEqual(sut.imageFormat, "JPEG")
    }

    func testShowInMenuBar_falseIsPersistedAndNotTreatedAsUnset() {
        sut.showInMenuBar = false
        XCTAssertFalse(sut.showInMenuBar, "false がデフォルト値 true に戻ってはいけない")
    }

    func testAppLanguage_roundTrips() {
        sut.appLanguage = "ja"
        XCTAssertEqual(sut.appLanguage, "ja")
    }

    func testFileNamePattern_roundTrips() {
        sut.fileNamePattern = "Shot_{date}"
        XCTAssertEqual(sut.fileNamePattern, "Shot_{date}")
    }

    // MARK: - saveDirectoryBookmark

    func testSaveDirectoryBookmark_roundTrips() {
        let bookmark = Data([0x01, 0x02, 0x03])
        sut.saveDirectoryBookmark = bookmark
        XCTAssertEqual(sut.saveDirectoryBookmark, bookmark)
    }

    func testSaveDirectoryBookmark_emptyDataIsTreatedAsUnset() {
        defaults.set(Data(), forKey: SettingsKey.saveDirectoryBookmark)
        XCTAssertNil(sut.saveDirectoryBookmark)
    }

    func testSaveDirectoryBookmark_settingNilClearsValue() {
        sut.saveDirectoryBookmark = Data([0x01])
        sut.saveDirectoryBookmark = nil
        XCTAssertNil(sut.saveDirectoryBookmark)
    }

    // MARK: - jpegQuality のクランプ

    func testJPEGQuality_withinRange_isStoredAsIs() {
        sut.jpegQuality = 50
        XCTAssertEqual(sut.jpegQuality, 50)
    }

    func testJPEGQuality_aboveMaximum_isClampedTo100() {
        sut.jpegQuality = 150
        XCTAssertEqual(sut.jpegQuality, 100)
    }

    func testJPEGQuality_belowMinimum_isClampedTo1() {
        sut.jpegQuality = -20
        XCTAssertEqual(sut.jpegQuality, 1)
    }

    func testJPEGQuality_readingOutOfRangeStoredValue_isClamped() {
        // 旧バージョンが範囲外の値を書き込んでいた場合も安全に読めること
        defaults.set(999.0, forKey: SettingsKey.jpegQuality)
        XCTAssertEqual(sut.jpegQuality, 100)
    }

    func testClampedJPEGQuality_withNaN_fallsBackToDefault() {
        XCTAssertEqual(AppSettings.clampedJPEGQuality(.nan), AppSettings.Default.jpegQuality)
    }

    func testJPEGQualityRange_matchesSliderBounds() {
        XCTAssertEqual(AppSettings.jpegQualityRange.lowerBound, 1)
        XCTAssertEqual(AppSettings.jpegQualityRange.upperBound, 100)
    }

    // MARK: - 分離

    func testSettings_doNotLeakIntoStandardDefaults() {
        sut.saveDirectory = "/tmp/isolated-check"
        XCTAssertNotEqual(
            UserDefaults.standard.string(forKey: SettingsKey.saveDirectory),
            "/tmp/isolated-check"
        )
    }
}
