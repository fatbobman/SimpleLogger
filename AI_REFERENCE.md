# SimpleLogger AI Reference

**Library**: SimpleLogger v0.5.0  
**Platform**: Swift 6.0+, iOS 14.0+, macOS 11.0+, Linux  
**Purpose**: Cross-platform logging with configurable backends

## Core API

### Primary Interface
```swift
protocol LoggerManagerProtocol: Sendable {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line)
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line)
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line)
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line)
}
```

### Log Levels
```swift
enum LogLevel: String, Comparable, Sendable {
    case debug, info, warning, error
}
```

### Console Verbosity
```swift
enum ConsoleVerbosity: Sendable {
    case silent      // No output
    case minimal     // Message only
    case standard    // Timestamp + level + message
    case detailed    // Full metadata
}
```

## Factory Methods

### Default Logger (Recommended)
```swift
// Apple platforms: OSLog, Others: Console
let logger = LoggerManager.default(subsystem: "com.app", category: "main")
```

### Console Logger
```swift
let logger = LoggerManager.console(
    subsystem: "AppName",
    category: "ComponentName", 
    verbosity: .standard,        // .silent, .minimal, .standard, .detailed
    useStderr: false,           // true for stderr, false for stdout
    enableColors: true          // ANSI colors (auto-detected)
)
```

### OSLog Backend (Apple only)
```swift
let logger = LoggerManager(backend: OSLogBackend(
    subsystem: "com.app.security",
    category: "auth",
    enhancedWarnings: false,    // true maps warnings to .fault
    environmentKey: "DisableLogger"
))
```

### Console Backend (Cross-platform)
```swift
let logger = LoggerManager(backend: ConsoleLogBackend(
    subsystem: "AppName",
    category: "Component",
    verbosity: .detailed,
    useStderr: false,
    enableColors: true,
    environmentKey: "DisableLogger"
))
```

## Usage Patterns

### Basic Logging
```swift
logger.info("User logged in: \(userID)")
logger.warning("API rate limit approaching")
logger.error("Database connection failed: \(error)")
```

### Platform-Specific
```swift
// Apple platforms (production)
let logger = LoggerManager.default(subsystem: "com.company.app", category: "network")

// Linux server (production)
let logger = LoggerManager.console(verbosity: .standard, useStderr: true, enableColors: false)

// Development (any platform)
let logger = LoggerManager.console(verbosity: .detailed, enableColors: true)
```

### Testing
```swift
struct TestLogger: LoggerManagerProtocol {
    let expectation: @Sendable (String, LogLevel) -> Void
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        expectation(message, level)
    }
}
```

### Environment Control
```bash
DisableLogger=true ./app           # Disable all default loggers
CUSTOM_LOG_DISABLE=true ./app      # Disable custom environment key
```

## Backend Protocol

### Custom Backend Implementation
```swift
struct CustomBackend: LoggerBackend {
    let subsystem: String
    let category: String
    
    func log(level: LogLevel, message: String, metadata: [String: String]?) {
        // Custom implementation
        // metadata contains: "file", "function", "line"
    }
}
```

## Key Behaviors

### Thread Safety
- All operations are async via DispatchQueue
- Sendable protocol compliance throughout

### Platform Adaptation
- `.default()` uses OSLog on Apple platforms, Console elsewhere
- Automatic fallback for older Apple platforms
- Cross-platform optimized buffering

### Performance
- Async logging prevents blocking
- OSLog automatically optimized by system
- Console backend includes flushing for immediate output

### Environment Variables
- Default key: "DisableLogger" 
- Values: "true", "1", "yes" (case-insensitive) disable logging
- Custom keys supported per backend

## Import Statement
```swift
import SimpleLogger
```

## Package.swift Integration
```swift
dependencies: [
    .package(url: "https://github.com/fatbobman/SimpleLogger.git", from: "0.5.0")
]
```

## Common Patterns for Code Generation

### Service Class Integration
```swift
class NetworkService {
    private let logger = LoggerManager.default(subsystem: "com.app", category: "network")
    
    func fetchData() async throws -> Data {
        logger.info("Starting data fetch")
        // implementation
        logger.info("Data fetch completed")
    }
}
```

### Error Handling
```swift
do {
    try riskyOperation()
    logger.info("Operation succeeded")
} catch {
    logger.error("Operation failed: \(error)")
    throw error
}
```

### Conditional Debug Logging
```swift
#if DEBUG
logger.debug("Detailed debug information: \(expensiveComputation())")
#endif
```