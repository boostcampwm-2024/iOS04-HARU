import OSLog

public struct PTGLogger {
    private let logger: Logger

    public init(subsystem: String = "PhotoGether", category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func log(
        _ message: String,
        level: OSLogType = .error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        logger.log(
            level: level,
            "[ 🚀 LOG ] \(fileName, privacy: .public):\(line) | \(function) | \(message, privacy: .public)"
        )
    }
}

public extension PTGLogger {
    static let `default` = PTGLogger(subsystem: "PhotoGether", category: "Default")
}
