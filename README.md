# SimpleLogger

A powerful yet simple logging library for Swift 6, providing comprehensive cross-platform logging with enhanced backends, configurable output levels, and seamless Apple ecosystem integration.

## Features

### 🚀 **Core Features**

- **Log Levels**: Supports `.debug`, `.info`, `.warning`, and `.error` levels with intelligent filtering
- **Cross-Platform**: Full support for Apple platforms, Linux, and other Unix-like systems
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
- **Comprehensive Documentation**: Built-in Claude Code development guidance

## Requirements

- **Swift 6.0+**
- **Apple Platforms**: iOS 14.0+, macOS 11.0+, watchOS 7.0+, tvOS 14.0+, visionOS 1.0+
- **Other Platforms**: Linux, other Unix-like systems with Swift support

## Installation

### Swift Package Manager

Add the package to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/fatbobman/SimpleLogger.git", from: "0.5.0")
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

// Default logger - OSLog on Apple platforms, Console elsewhere  
let logger: LoggerManagerProtocol = .default(subsystem: "com.yourapp", category: "main")

// Log at different levels
logger.debug("Debugging information")
logger.info("App started successfully")
logger.warning("Potential issue detected")
logger.error("Critical error occurred")
```

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

#### Linux/Cross-Platform

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

### 🧪 **Testing with Custom Loggers**

```swift
import Testing
import SimpleLogger

struct TestLogger: LoggerManagerProtocol {
    let expectation: @Sendable (String, LogLevel) -> Void
    
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        expectation(message, level)
    }
}

@Test func userServiceLogsCorrectly() async throws {
    var loggedMessages: [(String, LogLevel)] = []
    
    let testLogger = TestLogger { message, level in
        loggedMessages.append((message, level))
    }
    
    let userService = UserService(logger: testLogger)
    await userService.createUser(name: "John")
    
    #expect(loggedMessages.count == 1)
    #expect(loggedMessages[0].0.contains("User created"))
    #expect(loggedMessages[0].1 == .info)
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
// ✅ Good - Conditional expensive operations
if logger.isLoggingEnabled(for: .debug) {  // Hypothetical API
    let expensiveDebugInfo = generateDetailedReport()
    logger.debug("Debug report: \\(expensiveDebugInfo)")
}

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
