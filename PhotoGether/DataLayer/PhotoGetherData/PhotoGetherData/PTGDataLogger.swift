import OSLog

public enum PTGDataLogger {
    private static let logger = Logger(subsystem: "PhotoGether", category: "Data")
    
    public static func log(
        _ message: String,
        level: OSLogType = .error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        logger.log(
            level: level,
            "[ 🚀 DATA ] \(fileName, privacy: .public):\(line) | \(function) | \(message, privacy: .public)"
        )
    }
}
