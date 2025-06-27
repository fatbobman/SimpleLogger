import Foundation
import Synchronization

#if DEBUG

    /// A mock logger implementation for testing purposes.
    ///
    /// `MockLogBackend` captures all log calls in memory and provides various inspection methods
    /// to verify logging behavior in unit tests. It's thread-safe using `Synchronization.Mutex`
    /// and only available in DEBUG builds.
    ///
    /// ## Features
    /// - Thread-safe log capture using Swift 6 Synchronization framework
    /// - Comprehensive inspection methods for testing assertions
    /// - Async waiting capabilities for testing concurrent logging
    /// - Pattern matching and sequence verification
    /// - Available on all platforms that support Swift 6
    ///
    /// ## Usage
    /// ```swift
    /// let mockLogger = MockLogBackend()
    /// mockLogger.info("Test message")
    ///
    /// // Verify logging behavior
    /// XCTAssertTrue(mockLogger.hasInfoLogs)
    /// XCTAssertEqual(mockLogger.logCount(for: .info), 1)
    /// XCTAssertTrue(mockLogger.hasLog(level: .info, containing: "Test"))
    /// ```
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    public final class MockLogBackend: LoggerManagerProtocol {
        /// Thread-safe storage for captured log calls
        private let _logCalls: Mutex<[(level: LogLevel, message: String)]> = .init([])

        /// Returns all captured log calls as an array of (level, message) tuples.
        /// This property is thread-safe and returns a snapshot of all logs at the time of access.
        public var logCalls: [(level: LogLevel, message: String)] {
            _logCalls.withLock { $0 }
        }

        /// Initializes a new MockLogBackend instance.
        public init() {}

        /// Captures a log message with the specified level and metadata.
        /// This method is thread-safe and stores the log call for later inspection.
        ///
        /// - Parameters:
        ///   - message: The log message to capture
        ///   - level: The log level (debug, info, warning, error)
        ///   - file: The source file (metadata, not stored)
        ///   - function: The function name (metadata, not stored)
        ///   - line: The line number (metadata, not stored)
        public func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
            _logCalls.withLock { $0.append((level: level, message: message)) }
        }

        // MARK: - Test Helper Methods

        /// Clears all captured log entries.
        /// This method is thread-safe and removes all previously captured logs.
        public func clearLogs() {
            _logCalls.withLock { $0.removeAll() }
        }

        /// Checks if there's a log entry with the specified level containing the given substring.
        ///
        /// - Parameters:
        ///   - level: The log level to search for
        ///   - substring: The substring to search for in log messages
        /// - Returns: `true` if a matching log entry is found, `false` otherwise
        public func hasLog(level: LogLevel, containing substring: String) -> Bool {
            _logCalls.withLock { $0.contains { $0.level == level && $0.message.contains(substring) } }
        }

        /// Returns all log messages for a specific log level.
        ///
        /// - Parameter level: The log level to filter by
        /// - Returns: An array of log messages matching the specified level
        public func getLogMessages(for level: LogLevel) -> [String] {
            _logCalls.withLock { $0.filter { $0.level == level }.map(\.message) }
        }

        /// Returns the most recently captured log entry.
        ///
        /// - Returns: A tuple containing the level and message of the last log, or `nil` if no logs exist
        public func getLastLog() -> (level: LogLevel, message: String)? {
            _logCalls.withLock { $0.last }
        }
    }

    // MARK: - Convenience Extensions

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    extension MockLogBackend {
        // MARK: - Quick Log Level Checks

        /// Returns `true` if any error-level logs have been captured.
        public var hasErrorLogs: Bool {
            _logCalls.withLock { $0.contains { $0.level == .error } }
        }

        /// Returns `true` if any warning-level logs have been captured.
        public var hasWarningLogs: Bool {
            _logCalls.withLock { $0.contains { $0.level == .warning } }
        }

        /// Returns `true` if any info-level logs have been captured.
        public var hasInfoLogs: Bool {
            _logCalls.withLock { $0.contains { $0.level == .info } }
        }

        /// Returns `true` if any debug-level logs have been captured.
        public var hasDebugLogs: Bool {
            _logCalls.withLock { $0.contains { $0.level == .debug } }
        }

        /// Returns all captured log messages as an array of strings, regardless of level.
        public var allLogMessages: [String] {
            _logCalls.withLock { $0.map(\.message) }
        }

        // MARK: - Advanced Testing Methods

        /// Returns the number of logs captured for a specific level.
        ///
        /// - Parameter level: The log level to count
        /// - Returns: The number of logs at the specified level
        public func logCount(for level: LogLevel) -> Int {
            _logCalls.withLock { $0.count(where: { $0.level == level }) }
        }

        /// Verifies that the captured log sequence exactly matches the expected levels.
        ///
        /// - Parameter expectedLevels: The expected sequence of log levels
        /// - Returns: `true` if the actual log sequence matches the expected sequence exactly
        public func verifyLogSequence(_ expectedLevels: [LogLevel]) -> Bool {
            let actualLevels = _logCalls.withLock { $0.map(\.level) }
            return actualLevels == expectedLevels
        }

        /// Asynchronously waits for a log with the specified level and substring to appear.
        ///
        /// This method is useful for testing asynchronous logging operations. It polls
        /// the captured logs every 10ms until the specified log appears or the timeout expires.
        ///
        /// - Parameters:
        ///   - level: The log level to wait for
        ///   - substring: The substring to search for in the log message
        ///   - timeout: The maximum time to wait in seconds (default: 1.0)
        /// - Returns: `true` if the log appears within the timeout, `false` otherwise
        public func waitForLog(level: LogLevel, containing substring: String, timeout: TimeInterval = 1.0) async -> Bool {
            let startTime = Date()

            while Date().timeIntervalSince(startTime) < timeout {
                if hasLog(level: level, containing: substring) {
                    return true
                }
                // Brief wait before checking again
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
            }

            return false
        }

        /// Returns the total number of captured logs across all levels.
        public var totalLogCount: Int {
            _logCalls.withLock { $0.count }
        }

        /// Verifies that the last N captured logs match the expected level sequence.
        ///
        /// - Parameter expectedLevels: The expected sequence of the most recent log levels
        /// - Returns: `true` if the last N logs match the expected sequence, `false` otherwise
        public func verifyLastLogs(_ expectedLevels: [LogLevel]) -> Bool {
            let logs = _logCalls.withLock { $0 }
            guard logs.count >= expectedLevels.count else { return false }

            let lastLogs = Array(logs.suffix(expectedLevels.count))
            return lastLogs.map(\.level) == expectedLevels
        }

        /// Checks if there's a log entry at the specified level that matches a custom pattern.
        ///
        /// This method allows for complex log message validation using custom predicates.
        ///
        /// - Parameters:
        ///   - level: The log level to search within
        ///   - pattern: A closure that takes a log message and returns `true` if it matches the desired pattern
        /// - Returns: `true` if any log at the specified level matches the pattern, `false` otherwise
        ///
        /// Example:
        /// ```swift
        /// // Check if there's an info log that starts with "User"
        /// let hasUserLog = mockLogger.hasLogMatching(level: .info) { $0.hasPrefix("User") }
        ///
        /// // Check if there's an error log containing a specific error code
        /// let hasErrorCode = mockLogger.hasLogMatching(level: .error) { $0.contains("ERR_404") }
        /// ```
        public func hasLogMatching(level: LogLevel, pattern: (String) -> Bool) -> Bool {
            _logCalls.withLock { $0.contains { $0.level == level && pattern($0.message) } }
        }
    }

#endif
