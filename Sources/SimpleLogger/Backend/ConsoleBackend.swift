//
//  ------------------------------------------------
//  Original project: LoggerManager
//  Created on 2024/10/28 by Fatbobman(东坡肘子)
//  X: @fatbobman
//  Mastodon: @fatbobman@mastodon.social
//  GitHub: @fatbobman
//  Blog: https://fatbobman.com
//  ------------------------------------------------
//  Copyright © 2024-present Fatbobman. All rights reserved.

import Foundation

/// An implementation of the `LoggerBackend` protocol that logs messages to the console.
public final class ConsoleLogBackend: LoggerBackend {
    /// The subsystem name.
    public let subsystem: String

    /// The category name
    public let category: String
    
    /// The console output verbosity level
    public let verbosity: ConsoleVerbosity
    
    /// A boolean value that indicates whether the logger is enabled.
    let loggerEnabled: Bool
    
    /// Whether to use stderr instead of stdout
    public let useStderr: Bool
    
    /// Whether to enable ANSI color codes
    public let enableColors: Bool

    /// Initializes a `ConsoleLogBackend` instance with the specified subsystem.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem name.
    ///   - category: The category name.
    ///   - verbosity: The console output verbosity level.
    ///   - useStderr: Whether to use stderr instead of stdout for output.
    ///   - enableColors: Whether to enable ANSI color codes.
    ///   - environmentKey: The environment key to check for disabling the logger.
    public init(
        subsystem: String = "console logger", 
        category: String = "", 
        verbosity: ConsoleVerbosity = .detailed,
        useStderr: Bool = false,
        enableColors: Bool = true,
        environmentKey: String = "DisableLogger"
    ) {
        self.subsystem = subsystem
        self.category = category
        self.verbosity = verbosity
        self.useStderr = useStderr
        self.enableColors = enableColors
        if let value = ProcessInfo.processInfo.environment[environmentKey]?.lowercased() {
            loggerEnabled = !(value == "true" || value == "1" || value == "yes")
        } else {
            loggerEnabled = true
        }
    }

    /// A date formatter for formatting the timestamp.
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()

    /// Logs a message with the specified level, message, and metadata.
    ///
    /// - Parameters:
    ///   - level: The log level.
    ///   - message: The message to log.
    ///   - metadata: The metadata to log.
    public func log(level: LogLevel, message: String, metadata: [String: String]?) {
        guard loggerEnabled && verbosity != .silent else { return }
        
        let output: String
        switch verbosity {
        case .silent:
            return
        case .minimal:
            output = message
        case .standard:
            let timestamp = dateFormatter.string(from: Date())
            output = "\(timestamp) [\(level.rawValue.uppercased())] \(message)"
        case .detailed:
            let timestamp = dateFormatter.string(from: Date())
            let categoryPart = category.isEmpty ? "" : "[\(category)]"
            output = "\(timestamp) [\(level.rawValue.uppercased())] \(subsystem)\(categoryPart) \(message) in \(metadata?["function"] ?? "") at \(metadata?["file"] ?? ""):\(metadata?["line"] ?? "")"
        }
        
        writeToConsole(output)
    }
    
    /// Writes output to console with proper stream handling
    private func writeToConsole(_ message: String) {
        let finalMessage = enableColors ? colorizeMessage(message) : message
        let data = (finalMessage + "\n").data(using: .utf8) ?? Data()
        
        if useStderr {
            FileHandle.standardError.write(data)
            try? FileHandle.standardError.synchronize()  // Force flush - sufficient for most cases
        } else {
            FileHandle.standardOutput.write(data)
            try? FileHandle.standardOutput.synchronize()  // Force flush - sufficient for most cases
        }
    }
    
    /// Adds ANSI color codes to the message based on log level
    private func colorizeMessage(_ message: String) -> String {
        // Check if we're in a terminal that supports colors
        guard isatty(STDERR_FILENO) != 0 || isatty(STDOUT_FILENO) != 0 else {
            return message
        }
        
        // Simple color detection based on log level in the message
        if message.contains("[DEBUG]") {
            return "\u{001B}[90m\(message)\u{001B}[0m" // Gray
        } else if message.contains("[INFO]") {
            return "\u{001B}[36m\(message)\u{001B}[0m" // Cyan
        } else if message.contains("[WARNING]") {
            return "\u{001B}[33m\(message)\u{001B}[0m" // Yellow
        } else if message.contains("[ERROR]") {
            return "\u{001B}[31m\(message)\u{001B}[0m" // Red
        } else {
            return message
        }
    }
}
