# ``SimpleLogger``

A powerful yet simple logging library for Swift 6, providing comprehensive cross-platform logging with enhanced backends, configurable output levels, and seamless Apple ecosystem integration.

## Features

- **Log Levels**: Supports `.debug`, `.info`, `.warning`, and `.error` levels with intelligent filtering.
- **Cross-Platform**: Full support for Apple platforms, Linux, and other Unix-like systems.
- **Enhanced Console Backend**: Configurable verbosity levels, ANSI colors, and smart output routing.
- **Advanced OSLog Integration**: Privacy support, enhanced warning levels, and intelligent fallback.
- **Custom Backends**: Easily create custom log backends by conforming to `LoggerBackend`.
- **MockLogBackend**: Powerful testing utilities with thread-safe log capture and inspection.
- **Thread Safety**: Utilizes `DispatchQueue` and Swift 6 `Synchronization.Mutex` for thread-safe logging.
- **Environment Configurable**: Control logging output via environment variables.

## Usage

### Creating a Logger

#### Default OS Logger

```swift
let logger: LoggerManagerProtocol = .default(subsystem: "com.yourapp", category: "networking")
```

#### Console Logger

```swift
let logger: LoggerManagerProtocol = .console()
```

### Logging Messages

```swift
logger.debug("This is a debug message")
logger.info("This is an info message")
logger.warning("This is a warning message")
logger.error("This is an error message")
```

### Custom Logger Backend

Conform to `LoggerBackend` to create a custom backend:

```swift
public protocol LoggerBackend: Sendable {
    var subsystem: String { get }
    var category: String { get }
    func log(level: LogLevel, message: String, metadata: [String: String]?)
}
```

Example:

```swift
struct CustomLoggerBackend: LoggerBackend {
    let subsystem: String = "Custom Logger"
    
    func log(level: LogLevel, message: String, metadata: [String: String]?) {
        // Custom logging implementation
    }
}
```

### Disabling Logs

Set the `DisableLogger` environment variable to disable logging:

```swift
ProcessInfo.processInfo.environment["DisableLogger"] = "true"
```

## Examples

### Using the Default Logger

```swift
import SimpleLogger

let logger: LoggerManagerProtocol = .default(subsystem: "com.example.app", category: "general")
logger.info("App started")
```

### Using the Console Logger

```swift
import SimpleLogger

let logger: LoggerManagerProtocol = .console()
logger.debug("Debugging information")
```

## Enhanced Console Backend

The console backend supports multiple verbosity levels and advanced output features:

### Verbosity Levels

```swift
// Silent mode - no output
let silentLogger = LoggerManager.console(verbosity: .silent)

// Minimal - message only
let minimalLogger = LoggerManager.console(verbosity: .minimal)
// Output: "Hello, World!"

// Standard - timestamp + level + message  
let standardLogger = LoggerManager.console(verbosity: .standard)
// Output: "2024-06-22 10:30:15 [INFO] Hello, World!"

// Detailed - full metadata (default)
let detailedLogger = LoggerManager.console(verbosity: .detailed)
// Output: "2024-06-22 10:30:15 [INFO] MyApp[Category] Hello, World! in main() at main.swift:10"
```

### Colored Output and Advanced Features

```swift
// Linux-optimized logger with stderr and colors
let linuxLogger = LoggerManager.console(
    subsystem: "LinuxApp",
    category: "Service",
    verbosity: .standard,
    useStderr: true,      // Send logs to stderr (recommended for production)
    enableColors: true    // ANSI colors for better readability
)

// Production logger without colors
let prodLogger = LoggerManager.console(
    verbosity: .minimal,
    useStderr: true,
    enableColors: false   // No colors for log files
)
```

## Advanced OSLog Integration

Enhanced OSLog backend with privacy support and configurable warning levels:

```swift
// Enhanced OSLog with fault-level warnings
let osLogger = LoggerManager(backend: OSLogBackend(
    subsystem: "com.myapp.critical",
    category: "security", 
    enhancedWarnings: true  // Maps warnings to .fault for better visibility
))
```

## Testing with MockLogBackend

``MockLogBackend`` provides comprehensive testing capabilities for verifying logging behavior:

### Basic Testing

```swift
import Testing
@testable import SimpleLogger

@Test func userServiceLogsCorrectly() async throws {
    // Create a mock logger to capture log calls
    let mockLogger: LoggerManagerProtocol = .mock()  // Factory method
    // or alternatively: let mockLogger = MockLogBackend()
    let userService = UserService(logger: mockLogger)
    
    // Perform the operation
    await userService.createUser(name: "John")
    
    // Verify logging behavior
    let mock = mockLogger as! MockLogBackend  // Cast when using factory method
    #expect(mock.hasInfoLogs)
    #expect(mock.logCount(for: .info) == 1)
    #expect(mock.hasLog(level: .info, containing: "User created"))
    
    // Check specific log details
    let lastLog = mock.getLastLog()
    #expect(lastLog?.level == .info)
    #expect(lastLog?.message.contains("John"))
}
```

### Advanced Testing Features

```swift
@Test func asyncLoggingTest() async throws {
    let mockLogger = MockLogBackend()
    let service = AsyncService(logger: mockLogger)
    
    // Start async operation
    Task {
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms delay
        service.processData()
    }
    
    // Wait for the async log to appear
    let found = await mockLogger.waitForLog(
        level: .info, 
        containing: "Processing complete", 
        timeout: 0.2
    )
    #expect(found)
}

@Test func logSequenceVerification() async throws {
    let mockLogger = MockLogBackend()
    let workflow = DataWorkflow(logger: mockLogger)
    
    await workflow.execute()
    
    // Verify the exact sequence of log levels
    let expectedSequence: [LogLevel] = [.info, .debug, .info, .warning]
    #expect(mockLogger.verifyLogSequence(expectedSequence))
    
    // Verify last few logs only
    #expect(mockLogger.verifyLastLogs([.info, .warning]))
}

@Test func patternMatchingTest() async throws {
    let mockLogger = MockLogBackend()
    let apiClient = APIClient(logger: mockLogger)
    
    await apiClient.makeRequest(url: "https://api.example.com/users/123")
    
    // Complex pattern matching
    let hasAPICall = mockLogger.hasLogMatching(level: .info) { message in
        message.contains("API request") && message.contains("users/123")
    }
    #expect(hasAPICall)
    
    // Check for specific error patterns
    if mockLogger.hasErrorLogs {
        let hasTimeoutError = mockLogger.hasLogMatching(level: .error) { message in
            message.lowercased().contains("timeout")
        }
        // Handle timeout-specific test logic
    }
}
```

### MockLogBackend API Reference

``MockLogBackend`` provides comprehensive inspection methods:

```swift
// Quick level checks
mockLogger.hasDebugLogs     // Bool
mockLogger.hasInfoLogs      // Bool  
mockLogger.hasWarningLogs   // Bool
mockLogger.hasErrorLogs     // Bool

// Counting and filtering
mockLogger.totalLogCount                    // Int
mockLogger.logCount(for: .info)            // Int
mockLogger.getLogMessages(for: .error)     // [String]
mockLogger.allLogMessages                  // [String]

// Content searching
mockLogger.hasLog(level: .info, containing: "substring")
mockLogger.hasLogMatching(level: .error) { $0.contains("timeout") }

// Sequence verification
mockLogger.verifyLogSequence([.debug, .info, .warning])
mockLogger.verifyLastLogs([.info, .error])

// Async testing
await mockLogger.waitForLog(level: .info, containing: "complete", timeout: 1.0)

// Maintenance
mockLogger.clearLogs()                     // Clear all captured logs
mockLogger.getLastLog()                    // (level, message)?
```

### Simple Custom Logger (Alternative)

For simpler testing scenarios, you can also create a custom logger:

```swift
struct TestLogger: LoggerManagerProtocol {
    let expectation: @Sendable (String, LogLevel) -> Void
    
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        expectation(message, level)
    }
}

@Test func simpleLoggingTest() async throws {
    var capturedLog: (String, LogLevel)?
    
    let testLogger = TestLogger { message, level in
        capturedLog = (message, level)
    }
    
    let service = SimpleService(logger: testLogger)
    service.doSomething()
    
    #expect(capturedLog?.0.contains("Action completed"))
    #expect(capturedLog?.1 == .info)
}
```

## Topics

### Core Logging

- ``LoggerManagerProtocol``
- ``LoggerManager``
- ``LogLevel``

### Backends

- ``LoggerBackend``
- ``OSLogBackend``
- ``ConsoleLogBackend``

### Testing

- ``MockLogBackend``

### Utilities

- ``ConsoleVerbosity``


