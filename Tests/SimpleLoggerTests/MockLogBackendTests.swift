import Foundation
@testable import SimpleLogger
import Testing

#if DEBUG

    // MARK: - MockLogBackend Tests

    @Test("MockLogBackend - Basic logging capture")
    func mockLogBackendBasicLogging() async throws {
        let mockLogger = MockLogBackend()

        mockLogger.info("Test info message")
        mockLogger.warning("Test warning message")
        mockLogger.error("Test error message")

        #expect(mockLogger.logCalls.count == 3)
        #expect(mockLogger.logCalls[0].level == .info)
        #expect(mockLogger.logCalls[0].message == "Test info message")
        #expect(mockLogger.logCalls[1].level == .warning)
        #expect(mockLogger.logCalls[2].level == .error)
    }

    @Test("MockLogBackend - Clear logs function")
    func mockLogBackendClearLogs() async throws {
        let mockLogger = MockLogBackend()

        mockLogger.info("Message 1")
        mockLogger.info("Message 2")
        #expect(mockLogger.logCalls.count == 2)

        mockLogger.clearLogs()
        #expect(mockLogger.logCalls.isEmpty)
        #expect(mockLogger.logCalls.isEmpty)
    }

    @Test("MockLogBackend - Log level checking")
    func mockLogBackendLogLevelChecking() async throws {
        let mockLogger = MockLogBackend()

        mockLogger.debug("Debug message")
        mockLogger.info("Info message")
        mockLogger.warning("Warning message")
        mockLogger.error("Error message")

        #expect(mockLogger.hasDebugLogs)
        #expect(mockLogger.hasInfoLogs)
        #expect(mockLogger.hasWarningLogs)
        #expect(mockLogger.hasErrorLogs)
    }

    @Test("MockLogBackend - Specific level filtering")
    func mockLogBackendSpecificLevelFiltering() async throws {
        let mockLogger = MockLogBackend()

        mockLogger.info("Info 1")
        mockLogger.warning("Warning 1")
        mockLogger.info("Info 2")
        mockLogger.error("Error 1")
        mockLogger.info("Info 3")

        let infoMessages = mockLogger.getLogMessages(for: .info)
        let warningMessages = mockLogger.getLogMessages(for: .warning)
        let errorMessages = mockLogger.getLogMessages(for: .error)
        let debugMessages = mockLogger.getLogMessages(for: .debug)

        #expect(infoMessages.count == 3)
        #expect(warningMessages.count == 1)
        #expect(errorMessages.count == 1)
        #expect(debugMessages.isEmpty)

        #expect(infoMessages == ["Info 1", "Info 2", "Info 3"])
        #expect(warningMessages == ["Warning 1"])
        #expect(errorMessages == ["Error 1"])
    }

    @Test("MockLogBackend - Content searching")
    func mockLogBackendContentSearching() async throws {
        let mockLogger = MockLogBackend()

        mockLogger.info("User logged in successfully")
        mockLogger.warning("Database connection slow")
        mockLogger.error("Failed to authenticate user")
        mockLogger.info("User logged out")

        #expect(mockLogger.hasLog(level: .info, containing: "logged in"))
        #expect(mockLogger.hasLog(level: .info, containing: "logged out"))
        #expect(mockLogger.hasLog(level: .warning, containing: "Database"))
        #expect(mockLogger.hasLog(level: .error, containing: "authenticate"))

        #expect(!mockLogger.hasLog(level: .info, containing: "nonexistent"))
        #expect(!mockLogger.hasLog(level: .debug, containing: "logged in"))
    }

    @Test("MockLogBackend - Log count by level")
    func mockLogBackendLogCountByLevel() async throws {
        let mockLogger = MockLogBackend()

        mockLogger.debug("Debug 1")
        mockLogger.debug("Debug 2")
        mockLogger.info("Info 1")
        mockLogger.info("Info 2")
        mockLogger.info("Info 3")
        mockLogger.warning("Warning 1")
        mockLogger.error("Error 1")

        #expect(mockLogger.logCount(for: .debug) == 2)
        #expect(mockLogger.logCount(for: .info) == 3)
        #expect(mockLogger.logCount(for: .warning) == 1)
        #expect(mockLogger.logCount(for: .error) == 1)
        #expect(mockLogger.totalLogCount == 7)
    }

    @Test("MockLogBackend - Log sequence verification")
    func mockLogBackendLogSequenceVerification() async throws {
        let mockLogger = MockLogBackend()

        mockLogger.info("First")
        mockLogger.warning("Second")
        mockLogger.error("Third")
        mockLogger.debug("Fourth")

        let expectedSequence: [LogLevel] = [.info, .warning, .error, .debug]
        #expect(mockLogger.verifyLogSequence(expectedSequence))

        let wrongSequence: [LogLevel] = [.info, .error, .warning, .debug]
        #expect(!mockLogger.verifyLogSequence(wrongSequence))

        let partialSequence: [LogLevel] = [.info, .warning]
        #expect(!mockLogger.verifyLogSequence(partialSequence))
    }

    @Test("MockLogBackend - Last logs verification")
    func mockLogBackendLastLogsVerification() async throws {
        let mockLogger = MockLogBackend()

        mockLogger.debug("Old debug")
        mockLogger.info("Old info")
        mockLogger.warning("Recent warning")
        mockLogger.error("Recent error")
        mockLogger.info("Latest info")

        // Verify last 3 logs
        let lastThree: [LogLevel] = [.warning, .error, .info]
        #expect(mockLogger.verifyLastLogs(lastThree))

        // Verify last 2 logs
        let lastTwo: [LogLevel] = [.error, .info]
        #expect(mockLogger.verifyLastLogs(lastTwo))

        // Wrong last logs
        let wrongLast: [LogLevel] = [.info, .error, .warning]
        #expect(!mockLogger.verifyLastLogs(wrongLast))

        // More logs than available
        let tooMany: [LogLevel] = [.debug, .info, .warning, .error, .info, .debug]
        #expect(!mockLogger.verifyLastLogs(tooMany))
    }

    @Test("MockLogBackend - Pattern matching")
    func mockLogBackendPatternMatching() async throws {
        let mockLogger = MockLogBackend()

        mockLogger.info("User ID: 12345")
        mockLogger.info("User ID: 67890")
        mockLogger.warning("Invalid user input")
        mockLogger.error("Database error: Connection timeout")

        // Pattern matching with regex-like behavior
        #expect(mockLogger.hasLogMatching(level: .info) { $0.contains("User ID:") })
        #expect(mockLogger.hasLogMatching(level: .info) { $0.hasSuffix("12345") })
        #expect(mockLogger.hasLogMatching(level: .warning) { $0.hasPrefix("Invalid") })
        #expect(mockLogger.hasLogMatching(level: .error) { $0.contains("timeout") })

        // Pattern that doesn't match
        #expect(!mockLogger.hasLogMatching(level: .info) { $0.contains("nonexistent") })
        #expect(!mockLogger.hasLogMatching(level: .debug) { $0.contains("User ID:") })
    }

    @Test("MockLogBackend - Async log waiting")
    func mockLogBackendAsyncLogWaiting() async throws {
        let mockLogger = MockLogBackend()

        // Start async task that logs after delay
        Task {
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            mockLogger.info("Delayed message")
        }

        // Wait for the log to appear
        let found = await mockLogger.waitForLog(level: .info, containing: "Delayed", timeout: 0.2)
        #expect(found)

        // Test timeout scenario
        let notFound = await mockLogger.waitForLog(level: .error, containing: "Never logged", timeout: 0.1)
        #expect(!notFound)
    }

    @Test("MockLogBackend - Empty logger state")
    func mockLogBackendEmptyLoggerState() async throws {
        let mockLogger = MockLogBackend()

        #expect(mockLogger.logCalls.isEmpty)
        #expect(mockLogger.totalLogCount == 0)
        #expect(!mockLogger.hasDebugLogs)
        #expect(!mockLogger.hasInfoLogs)
        #expect(!mockLogger.hasWarningLogs)
        #expect(!mockLogger.hasErrorLogs)
        #expect(mockLogger.allLogMessages.isEmpty)
        #expect(mockLogger.getLastLog() == nil)

        // Test methods with empty state
        #expect(mockLogger.logCount(for: .info) == 0)
        #expect(mockLogger.verifyLogSequence([]))
        #expect(!mockLogger.verifyLastLogs([.info]))
        #expect(!mockLogger.hasLogMatching(level: .info) { _ in true })
    }

    @Test("MockLogBackend - Large volume logging")
    func mockLogBackendLargeVolumeLogging() async throws {
        let mockLogger = MockLogBackend()

        // Add many logs
        for i in 0 ..< 1000 {
            switch i % 4 {
                case 0: mockLogger.debug("Debug \(i)")
                case 1: mockLogger.info("Info \(i)")
                case 2: mockLogger.warning("Warning \(i)")
                case 3: mockLogger.error("Error \(i)")
                default: break
            }
        }

        #expect(mockLogger.totalLogCount == 1000)
        #expect(mockLogger.logCount(for: .debug) == 250)
        #expect(mockLogger.logCount(for: .info) == 250)
        #expect(mockLogger.logCount(for: .warning) == 250)
        #expect(mockLogger.logCount(for: .error) == 250)

        // Test specific log retrieval
        let lastLog = mockLogger.getLastLog()
        #expect(lastLog?.level == .error)
        #expect(lastLog?.message == "Error 999")

        // Test pattern matching on large dataset - info messages are at indices 1, 5, 9, 13, etc.
        #expect(mockLogger.hasLogMatching(level: .info) { $0.contains("Info 501") })
    }

    @Test("MockLogBackend - Concurrent logging")
    func mockLogBackendConcurrentLogging() async throws {
        let mockLogger = MockLogBackend()

        // Create multiple concurrent tasks
        await withTaskGroup(of: Void.self) { group in
            for i in 0 ..< 100 {
                group.addTask {
                    mockLogger.info("Concurrent message \(i)")
                }
            }
        }

        // Verify all logs were captured
        #expect(mockLogger.totalLogCount == 100)
        #expect(mockLogger.logCount(for: .info) == 100)

        // Verify all messages are present (order may vary due to concurrency)
        let messages = mockLogger.allLogMessages
        for i in 0 ..< 100 {
            #expect(messages.contains("Concurrent message \(i)"))
        }
    }

#endif
