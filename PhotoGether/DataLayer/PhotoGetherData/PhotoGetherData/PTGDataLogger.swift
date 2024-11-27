import OSLog

public enum PTGDataLogger {
    private static let logger = Logger(subsystem: "PhotoGether", category: "Data")
    
    public static func log(level: OSLogType = .default, _ message: String) {
        logger.log(level: level, "[ 🚀 DATA ] \(message, privacy: .public)")
    }
}
