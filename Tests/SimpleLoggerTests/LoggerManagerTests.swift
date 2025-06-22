@testable import SimpleLogger
import Testing
import Foundation

/// add `DisableLogger = true` in environment variables can disable log output
@Test func osLoggerTest() async throws {
    let logger: LoggerManagerProtocol = .default(subsystem: "test", category: "default")
    logger.info("Hello, World!")
}

@Test func consoleLoggerTest() async throws {
    let logger: LoggerManagerProtocol = .console()
    logger.info("Hello, World!")
    
    // Small delay to ensure async logging completes before test ends
    try await Task.sleep(nanoseconds: 10_000_000) // 10ms
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
    let customLogger = LoggerManager(backend: ConsoleLogBackend(
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
    let stderrLogger = LoggerManager(backend: ConsoleLogBackend(
        subsystem: "StdErr", 
        category: "Test",
        verbosity: .standard,
        useStderr: true,
        enableColors: true
    ))
    
    let stdoutLogger = LoggerManager(backend: ConsoleLogBackend(
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
        let standardLogger = LoggerManager(backend: OSLogBackend(
            subsystem: "test.standard", 
            category: "warnings"
        ))
        
        // Test enhanced warnings
        let enhancedLogger = LoggerManager(backend: OSLogBackend(
            subsystem: "test.enhanced", 
            category: "warnings",
            enhancedWarnings: true
        ))
        
        standardLogger.warning("Standard warning mapping")
        enhancedLogger.warning("Enhanced warning mapping (fault level)")
        
        // Small delay for async logging
        try await Task.sleep(nanoseconds: 10_000_000)
        
        print("=== End OSLog Enhanced Warnings Test ===\n")
    }
    #endif
}

struct CustomLogger: LoggerManagerProtocol {
    let expect: @Sendable (String, LogLevel) -> Void
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        expect(message, level)
    }
}
