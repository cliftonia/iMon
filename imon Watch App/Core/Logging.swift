import os

nonisolated enum Log {
    static let engine = Logger(subsystem: "com.cliftonia.imon", category: "engine")
    static let presentation = Logger(subsystem: "com.cliftonia.imon", category: "presentation")
    static let health = Logger(subsystem: "com.cliftonia.imon", category: "health")
    static let sprites = Logger(subsystem: "com.cliftonia.imon", category: "sprites")
}
