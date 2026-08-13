import os

enum AppLogger {
    static let app = Logger(subsystem: "com.shuhei.ishihara.MySnapApp", category: "app")
    static let capture = Logger(subsystem: "com.shuhei.ishihara.MySnapApp", category: "capture")
    static let fileService = Logger(subsystem: "com.shuhei.ishihara.MySnapApp", category: "fileService")
    static let settings = Logger(subsystem: "com.shuhei.ishihara.MySnapApp", category: "settings")
}
