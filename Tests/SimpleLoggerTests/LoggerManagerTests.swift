import Foundation
import Testing

@testable import SimpleLogger

/// add `DisableLogger = true` in environment variables can disable log output
@Test func osLoggerTest() async throws {
    let logger: LoggerManagerProtocol = .default(subsystem: "test", category: "default")
    logger.info("Hello, World!")
    logger.flush()
}

@Test func consoleLoggerTest() async throws {
    let logger: LoggerManagerProtocol = .console()
    logger.info("Hello, World!")
    logger.flush()
}

@Test func customLoggerTest() async throws {
    let logger: LoggerManagerProtocol = CustomLogger(expect: { meg, level in
        #expect(meg == "Hello, World!")
        #expect(level == .info)
    })
    logger.info("Hello, World!")
}

@Test func consoleVerbosityTest() async throws {
    print("\n=== Testing Console Verbosity Levels ===")

    print("\n1. Silent mode (should show nothing):")
    let silentLogger: LoggerManagerProtocol = .console(verbosity: .silent)
    silentLogger.info("This should not appear")

    print("\n2. Minimal mode:")
    let minimalLogger: LoggerManagerProtocol = .console(verbosity: .minimal)
    minimalLogger.info("Just the message")

    print("\n3. Standard mode:")
    let standardLogger: LoggerManagerProtocol = .console(verbosity: .standard)
    standardLogger.info("Message with timestamp and level")

    print("\n4. Detailed mode:")
    let detailedLogger: LoggerManagerProtocol = .console(verbosity: .detailed)
    detailedLogger.info("Full detailed message")

    print("=== End Verbosity Test ===\n")
}

@Test func consoleEnvironmentDisableTest() async throws {
    print("\n=== Testing Environment Variable Disable ===")

    // Test with custom environment key
    let customLogger = LoggerManager(
        backend: ConsoleLogBackend(
            subsystem: "test",
            category: "env",
            verbosity: .minimal,
            environmentKey: "CUSTOM_DISABLE"
        ))

    print("Testing with CUSTOM_DISABLE not set (should show message):")
    customLogger.info("This should appear")

    print("=== End Environment Test ===\n")
}

@Test func consoleOutputFeaturesTest() async throws {
    print("\n=== Testing Console Output Features ===")

    // Test different output configurations
    let stderrLogger = LoggerManager(
        backend: ConsoleLogBackend(
            subsystem: "StdErr",
            category: "Test",
            verbosity: .standard,
            useStderr: true,
            enableColors: true
        ))

    let stdoutLogger = LoggerManager(
        backend: ConsoleLogBackend(
            subsystem: "StdOut",
            category: "Test",
            verbosity: .standard,
            useStderr: false,
            enableColors: false
        ))

    print("Testing different log levels with colors (stderr):")
    stderrLogger.debug("Debug message")
    stderrLogger.info("Info message")
    stderrLogger.warning("Warning message")
    stderrLogger.error("Error message")

    print("\nTesting stdout without colors:")
    stdoutLogger.info("Stdout message without colors")

    print("=== End Output Features Test ===\n")
}

@Test func osLogEnhancedWarningsTest() async throws {
    #if canImport(OSLog)
        if #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, visionOS 1.0, *) {
            print("\n=== Testing OSLog Enhanced Warnings ===")

            // Test standard warnings
            let standardLogger = LoggerManager(
                backend: OSLogBackend(
                    subsystem: "test.standard",
                    category: "warnings"
                ))

            // Test enhanced warnings
            let enhancedLogger = LoggerManager(
                backend: OSLogBackend(
                    subsystem: "test.enhanced",
                    category: "warnings",
                    enhancedWarnings: true
                ))

            standardLogger.warning("Standard warning mapping")
            enhancedLogger.warning("Enhanced warning mapping (fault level)")

            standardLogger.flush()
            enhancedLogger.flush()

            print("=== End OSLog Enhanced Warnings Test ===\n")
        }
    #endif
}

@Test func loggerManagerFlushEnsuresDelivery() async throws {
    let backend = RecordingBackend(subsystem: "flush.test", category: "delivery")
    let logger = LoggerManager(backend: backend)

    logger.info("First")
    logger.warning("Second")

    logger.flush()

    #expect(backend.messages == ["First", "Second"])
}

@Test func loggerManagerPreservesLogOrder() async throws {
    let backend = RecordingBackend(subsystem: "flush.test", category: "order")
    let logger = LoggerManager(backend: backend)

    for index in 0..<20 {
        logger.info("Message \(index)")
    }

    logger.flush()

    #expect(backend.messages == (0..<20).map { "Message \($0)" })
}

@Test func flushIsSafeForSynchronousLoggers() async throws {
    let logger = CustomLogger(expect: { _, _ in })
    logger.info("Hello, World!")
    logger.flush()
}

@Test func osLogBackendTrimsSubsystemAndCategory() async throws {
    #if canImport(OSLog)
        if #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, visionOS 1.0, *) {
            let backend = OSLogBackend(
                subsystem: "  test.subsystem  ",
                category: "  category  "
            )

            #expect(backend.subsystem == "test.subsystem")
            #expect(backend.category == "category")
        }
    #endif
}

@Test func defaultFactoryConfiguresConsoleFallback() async throws {
    #if !canImport(OSLog)
        let logger = LoggerManager.default(
            subsystem: "console.default",
            category: "fallback",
            useStderr: true
        )

        let backend = logger.backend as? ConsoleLogBackend
        #expect(backend != nil)
        #expect(backend?.subsystem == "console.default")
        #expect(backend?.category == "fallback")
        #expect(backend?.verbosity == .standard)
        #expect(backend?.useStderr == true)
    #else
        #expect(Bool(true))
    #endif
}

struct CustomLogger: LoggerManagerProtocol {
    let expect: @Sendable (String, LogLevel) -> Void
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        expect(message, level)
    }
}

final class RecordingBackend: LoggerBackend, @unchecked Sendable {
    let subsystem: String
    let category: String

    private let lock = NSLock()
    private var storedMessages: [String] = []

    init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }

    var messages: [String] {
        lock.lock()
        defer { lock.unlock() }
        return storedMessages
    }

    func log(level: LogLevel, message: String, metadata: [String: String]?) {
        lock.lock()
        defer { lock.unlock() }
        storedMessages.append(message)
    }
}
