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

/// A protocol that defines the interface for a logger manager.
public protocol LoggerManagerProtocol: Sendable {
    /// Logs a message with the specified level, file, function, and line.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The log level.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int)
}

/// Default implementations for the `LoggerManagerProtocol`.
extension LoggerManagerProtocol {
    /// Logs a debug message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }

    /// Logs an info message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }

    /// Logs a warning message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }

    /// Logs an error message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file name.
    ///   - function: The function name.
    ///   - line: The line number.
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}

/// Default implementations for the `LoggerManagerProtocol`.
extension LoggerManagerProtocol where Self == LoggerManager {
    /// Creates a default `LoggerManager` instance with the specified subsystem and category.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem name.
    ///   - category: The category name.
    public static func `default`(subsystem: String, category: String) -> Self {
        #if canImport(OSLog)
            if #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, visionOS 1.0, *) {
                LoggerManager(backend: OSLogBackend(subsystem: subsystem, category: category))
            } else {
                LoggerManager(backend: ConsoleLogBackend(subsystem: subsystem, category: category, verbosity: .standard, useStderr: false))
            }
        #else
            LoggerManager(backend: ConsoleLogBackend(subsystem: subsystem, category: category, verbosity: .standard, useStderr: false))
        #endif
    }

    /// Creates a `LoggerManager` instance that logs to the console.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem name.
    ///   - category: The category name.
    ///   - verbosity: The console output verbosity level.
    ///   - useStderr: Whether to use stderr instead of stdout for output.
    ///   - enableColors: Whether to enable ANSI color codes.
    public static func console(
        subsystem: String = "Console Logger",
        category: String = "",
        verbosity: ConsoleVerbosity = .detailed,
        useStderr: Bool = false, // Default to stdout for better visibility in tests
        enableColors: Bool = true) -> Self
    {
        LoggerManager(backend: ConsoleLogBackend(
            subsystem: subsystem,
            category: category,
            verbosity: verbosity,
            useStderr: useStderr,
            enableColors: enableColors))
    }
}

#if DEBUG
    extension LoggerManagerProtocol where Self == MockLogBackend {
        /// Creates a mock logger for testing purposes.
        ///
        /// This factory method provides a convenient way to create a ``MockLogBackend`` instance
        /// for use in unit tests and test scenarios.
        ///
        /// - Returns: A new ``MockLogBackend`` instance ready for testing
        public static func mock() -> Self {
            MockLogBackend()
        }
    }
#endif
