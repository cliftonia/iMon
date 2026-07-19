import os

/// One `os.Logger` per layer so Console filtering follows the architecture.
nonisolated enum Log {
    private static let subsystem = "com.cliftonia.imon"

    static let engine = Logger(subsystem: subsystem, category: "engine")
    static let presentation = Logger(subsystem: subsystem, category: "presentation")
    static let weather = Logger(subsystem: subsystem, category: "weather")
    static let health = Logger(subsystem: subsystem, category: "health")
    static let background = Logger(subsystem: subsystem, category: "background")
}
