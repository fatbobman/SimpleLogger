# SimpleLogger

**English | [中文](README-zh.md)**

A powerful yet simple logging library for Swift 6, providing comprehensive cross-platform logging with enhanced backends, configurable output levels, and seamless Apple ecosystem integration.

![Swift 6](https://img.shields.io/badge/Swift-6-orange?logo=swift) ![iOS](https://img.shields.io/badge/iOS-14.0+-green) ![macOS](https://img.shields.io/badge/macOS-11.0+-green) ![watchOS](https://img.shields.io/badge/watchOS-7.0+-green) ![visionOS](https://img.shields.io/badge/visionOS-1.0+-green) ![tvOS](https://img.shields.io/badge/tvOS-14.0+-green) ![Android](https://img.shields.io/badge/Android-Experimental-yellow) [![Linux Tests](https://github.com/fatbobman/SimpleLogger/actions/workflows/linux-test.yml/badge.svg)](https://github.com/fatbobman/SimpleLogger/actions/workflows/linux-test.yml) [![Android Build](https://github.com/fatbobman/SimpleLogger/actions/workflows/android-test.yml/badge.svg)](https://github.com/fatbobman/SimpleLogger/actions/workflows/android-test.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/fatbobman/SimpleLogger)

## Features

### 🚀 **Core Features**

- **Log Levels**: Supports `.debug`, `.info`, `.warning`, and `.error` levels with intelligent filtering
- **Cross-Platform**: Support for Apple platforms, Linux, Android (experimental build support), and other Unix-like systems
- **Thread Safety**: Utilizes `DispatchQueue` for thread-safe asynchronous logging
- **Environment Configurable**: Flexible logging control via environment variables

### 🎛 **Enhanced Console Backend**

- **Configurable Verbosity**: Silent, minimal, standard, and detailed output levels
- **Smart Output Routing**: Choose between stdout/stderr for proper log separation
- **ANSI Colors**: Beautiful colored output with automatic terminal detection
- **Cross-Platform Optimization**: Optimized buffering and flushing for Linux/Unix systems

### 🍎 **Advanced OSLog Integration**

- **Privacy Support**: Automatic privacy annotations for iOS 14.0+
- **Enhanced Warning Levels**: Optional fault-level mapping for critical warnings
- **Input Validation**: Robust error handling and configuration validation
- **Intelligent Fallback**: Automatic fallback to console logging on older platforms

### 🔧 **Developer Experience**

- **Custom Backends**: Easily create custom log backends by conforming to `LoggerBackend`
- **Protocol-Oriented Design**: Clean abstractions for testing and mocking
- **MockLogBackend**: Powerful testing utilities with thread-safe log capture and inspection
- **Comprehensive Documentation**: Repository guidance for coding agents and contributors

## Requirements

- **Swift 6.0+**
- **Apple Platforms**: iOS 14.0+, macOS 11.0+, watchOS 7.0+, tvOS 14.0+, visionOS 1.0+
- **Other Platforms**: Linux, Android (experimental build support), and other Unix-like systems with Swift support

## CI

- `linux-test.yml`: Builds the package and runs the Linux test matrix in GitHub Actions
- `android-test.yml`: Verifies Android cross-compilation in GitHub Actions

## Installation

### Swift Package Manager

Add the package to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/fatbobman/SimpleLogger.git", from: "0.7.0")
]
```

Then import the module in your code:

```swift
import SimpleLogger
```

## Quick Start

### 🎯 **Basic Usage**

```swift
import SimpleLogger

// Default logger - OSLog on supported Apple platforms, Console elsewhere
let logger: LoggerManagerProtocol = .default(subsystem: "com.yourapp", category: "main")

// Log at different levels
logger.debug("Debugging information")
logger.info("App started successfully")
logger.warning("Potential issue detected")
logger.error("Critical error occurred")
```

### ⏳ **Draining Async Logs**

`LoggerManager` remains asynchronous by default. For short-lived processes such as CLI tools or tests, call `flush()` before exit to ensure queued log messages have been handed off to the backend.

```swift
let logger: LoggerManagerProtocol = .console()
logger.info("Finishing work")
logger.flush()
```

`LoggerManager.default(subsystem:category:useStderr:)` uses `OSLogBackend` on supported Apple platforms and falls back to `ConsoleLogBackend(verbosity: .standard)` elsewhere. The `useStderr` argument only affects the non-Apple console fallback path.

### 📱 **Platform-Specific Configuration**

#### Apple Platforms (Recommended)

```swift
// Standard OSLog integration
let logger: LoggerManagerProtocol = .default(subsystem: "com.yourapp", category: "networking")

// Enhanced OSLog with fault-level warnings
let criticalLogger = LoggerManager(backend: OSLogBackend(
    subsystem: "com.yourapp.security", 
    category: "auth",
    enhancedWarnings: true  // Maps warnings to .fault for better visibility
))
```

#### Linux/Android/Cross-Platform

```swift
// Production-ready console logger
let serverLogger = LoggerManager.console(
    subsystem: "MyServer",
    category: "API", 
    verbosity: .standard,
    useStderr: true,      // Send logs to stderr
    enableColors: false   // Disable colors for log files
)

// Development console logger
let devLogger = LoggerManager.console(
    verbosity: .detailed,  // Full metadata
    enableColors: true     // Colored output
)

// Android-oriented configuration
// Note: ANSI colors are disabled by the backend on Android targets
let androidLogger = LoggerManager.console(
    subsystem: "AndroidApp",
    category: "Main",
    verbosity: .standard,
    useStderr: true       // Recommended for Android logging
)

// Default fallback logger for non-Apple platforms
let fallbackLogger: LoggerManagerProtocol = .default(
    subsystem: "MyServer",
    category: "API",
    useStderr: true
)
```

## Advanced Features

### 🎛 **Console Verbosity Levels**

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

### 🌈 **Colored Output**

```swift
// Automatic color detection
let colorLogger = LoggerManager.console(enableColors: true)

// Colors by log level:
// 🔍 DEBUG: Gray
// ℹ️ INFO: Cyan  
// ⚠️ WARNING: Yellow
// ❌ ERROR: Red

// Production - disable colors for log files
let prodLogger = LoggerManager.console(enableColors: false)

// Note: Colors are disabled on Android targets
```

### 🔧 **Environment Control**

```bash
# Disable all logging
DisableLogger=true ./myapp

# Custom environment keys
DISABLE_NETWORK_LOGS=true ./myapp
```

```swift
// Custom environment key
let logger = LoggerManager(backend: ConsoleLogBackend(
    subsystem: "NetworkService",
    environmentKey: "DISABLE_NETWORK_LOGS"
))

// Multiple loggers with different controls
let apiLogger = LoggerManager(backend: OSLogBackend(
    subsystem: "com.app.api",
    category: "requests", 
    environmentKey: "DISABLE_API_LOGS"
))
```

### 🎨 **Custom Backends**

Create powerful custom backends by conforming to `LoggerBackend`:

```swift
struct FileLoggerBackend: LoggerBackend {
    let subsystem: String
    let category: String
    private let fileURL: URL
    
    init(subsystem: String, category: String, logFile: URL) {
        self.subsystem = subsystem
        self.category = category
        self.fileURL = logFile
    }
    
    func log(level: LogLevel, message: String, metadata: [String: String]?) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logLine = "[\(timestamp)] [\(level.rawValue.uppercased())] \(message)\n"
        
        try? logLine.data(using: .utf8)?.write(to: fileURL, options: .atomic)
    }
}

// Usage
let fileLogger = LoggerManager(backend: FileLoggerBackend(
    subsystem: "com.app.file",
    category: "storage", 
    logFile: URL(fileURLWithPath: "/var/log/myapp.log")
))
```

## Real-World Examples

### 📱 **iOS/macOS App**

```swift
import SimpleLogger

class AppDelegate {
    // Main app logger with enhanced warnings for critical issues
    private let appLogger = LoggerManager(backend: OSLogBackend(
        subsystem: "com.mycompany.myapp",
        category: "lifecycle",
        enhancedWarnings: true
    ))
    
    // Network layer with separate category
    private let networkLogger = LoggerManager.default(
        subsystem: "com.mycompany.myapp", 
        category: "network"
    )
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appLogger.info("App launched successfully")
        return true
    }
}
```

### 📱 **Android Application**

```swift
import SimpleLogger

class AndroidApp {
    // Console logger configured for an Android target
    private let logger = LoggerManager.console(
        subsystem: "com.example.androidapp",
        category: "main",
        verbosity: .standard,
        useStderr: true,      // Recommended for Android
        enableColors: false   // Colors are disabled on Android targets
    )
    
    func onCreate() {
        logger.info("Android app started")
        
        // Logs are still emitted through the console backend
        logger.debug("Debug information")
        logger.warning("Warning message")
        logger.error("Error occurred")
    }
}
```

### 🖥️ **Linux Server Application**

```swift
import SimpleLogger

class WebServer {
    // Access logs to stdout for log aggregation
    private let accessLogger = LoggerManager.console(
        subsystem: "WebServer",
        category: "Access",
        verbosity: .minimal,
        useStderr: false,     // stdout for access logs
        enableColors: false   // no colors in production
    )
    
    // Error logs to stderr with colors for development
    private let errorLogger = LoggerManager.console(
        subsystem: "WebServer", 
        category: "Error",
        verbosity: .detailed,
        useStderr: true,      // stderr for errors
        enableColors: true
    )
    
    func handleRequest(_ request: Request) {
        accessLogger.info("\\(request.method) \\(request.path) - \\(request.clientIP)")
        
        do {
            try processRequest(request)
        } catch {
            errorLogger.error("Request failed: \\(error)")
        }
    }
}
```

### 🧪 **Testing with MockLogBackend**

SimpleLogger provides a powerful `MockLogBackend` for comprehensive testing scenarios:

```swift
import Testing
import SimpleLogger

@Test func userServiceLogsCorrectly() async throws {
    // Create a mock logger to capture log calls
    let mockLogger = MockLogBackend()
    let userService = UserService(logger: mockLogger)
    
    // Perform the operation
    await userService.createUser(name: "John")
    
    // Verify logging behavior
    #expect(mockLogger.hasInfoLogs)
    #expect(mockLogger.logCount(for: .info) == 1)
    #expect(mockLogger.hasLog(level: .info, containing: "User created"))
    
    // Check specific log details
    let lastLog = mockLogger.getLastLog()
    #expect(lastLog?.level == .info)
    #expect(lastLog?.message.contains("John"))
}

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

#### MockLogBackend Features

- **Thread-Safe**: Uses `NSLock` for concurrent access inside `MockLogBackend`
- **Comprehensive Inspection**: Check logs by level, content, patterns, and sequences
- **Async Support**: `waitForLog()` method for testing asynchronous operations
- **Cross-Platform**: Available on all platforms supporting Swift 6
- **Debug-Only**: Only compiled in DEBUG builds to avoid production overhead

#### Available Testing Methods

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

### 🎨 **Custom Testing Logger (Alternative)**

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

## Best Practices

### 🎯 **Subsystem and Category Naming**

```swift
// Use reverse DNS for subsystems
let logger = LoggerManager.default(
    subsystem: "com.yourcompany.yourapp",    // Unique identifier
    category: "authentication"               // Functional area
)

// Examples of good category names:
// - "network", "database", "ui", "auth", "payment"
// - "lifecycle", "performance", "security"
```

### ⚡ **Performance Considerations**

```swift
// ✅ Good - Gate expensive debug work behind build configuration
#if DEBUG
let expensiveDebugInfo = generateDetailedReport()
logger.debug("Debug report: \\(expensiveDebugInfo)")
#endif

// ✅ Good - Simple messages are fine
logger.info("User logged in: \\(userID)")

// ❌ Avoid - Expensive string interpolation for debug messages in production
logger.debug("Complex calculation result: \\(performExpensiveCalculation())")
```

### 🔒 **Security and Privacy**

```swift
// ✅ Good - Don't log sensitive information
logger.info("User authentication successful for user: \\(userID)")

// ❌ Bad - Logging sensitive data
logger.info("User logged in with password: \\(password)")  // Never do this!

// ✅ Good - Use appropriate log levels
logger.error("Authentication failed")           // Error level for failures
logger.warning("Unusual login pattern detected") // Warning for suspicious activity
logger.info("User session started")             // Info for normal operations
logger.debug("JWT token validation steps")      // Debug for development only
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Support the project

- [🎉 Subscribe to my Swift Weekly](https://weekly.fatbobman.com)
- [☕️ Buy Me A Coffee](https://buymeacoffee.com/fatbobman)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=fatbobman/SimpleLogger&type=Date)](https://star-history.com/#fatbobman/SimpleLogger&Date)
