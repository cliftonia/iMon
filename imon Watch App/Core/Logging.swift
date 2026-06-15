import os

nonisolated enum Log {
    static let engine = Logger(subsystem: "com.cliftonia.imon", category: "engine")
    static let presentation = Logger(subsystem: "com.cliftonia.imon", category: "presentation")
    static let weather = Logger(subsystem: "com.cliftonia.imon", category: "weather")
    static let health = Logger(subsystem: "com.cliftonia.imon", category: "health")
}
