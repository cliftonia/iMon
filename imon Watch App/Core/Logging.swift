import os

/// One `os.Logger` per layer so Console filtering follows the architecture.
nonisolated enum Log {
    private static let subsystem = "com.cliftonia.stepkin"

    /// Logger for the engine layer.
    static let engine = Logger(subsystem: subsystem, category: "engine")
    /// Logger for the presentation layer.
    static let presentation = Logger(subsystem: subsystem, category: "presentation")
    /// Logger for the weather layer.
    static let weather = Logger(subsystem: subsystem, category: "weather")
    /// Logger for the health layer.
    static let health = Logger(subsystem: subsystem, category: "health")
    /// Logger for the background layer.
    static let background = Logger(subsystem: subsystem, category: "background")
}
