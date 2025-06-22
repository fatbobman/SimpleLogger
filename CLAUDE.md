# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SimpleLogger is a Swift 6 logging library that provides a thread-safe, backend-agnostic logging system. The architecture follows a protocol-oriented design with pluggable backends.

## Build and Test Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Run tests with specific test plan
swift test --testplan LoggerManager.xctestplan

# Build for specific platform
swift build --platform ios
swift build --platform macos

# Test on Linux (requires Swift toolchain)
swift test
```

## Architecture

### Core Components

- **LoggerManagerProtocol** (`Sources/SimpleLogger/LoggerManagerProtocol.swift`): Main interface with convenience methods (debug, info, warning, error)
- **LoggerManager** (`Sources/SimpleLogger/LoggerManager.swift`): Concrete implementation that manages a backend and dispatch queue for thread safety
- **LoggerBackend** (`Sources/SimpleLogger/Backend/LoggerBackendProtocol.swift`): Protocol for pluggable logging backends
- **LogLevel** (`Sources/SimpleLogger/LogLevel.swift`): Comparable enum for log levels (.debug, .info, .warning, .error)

### Built-in Backends

- **OSLogBackend** (`Sources/SimpleLogger/Backend/OSLogBackend.swift`): Enhanced implementation of Apple's unified logging system with privacy support, configurable warning levels, input validation, and optimized performance. Only available on Apple platforms (`#if canImport(OSLog)`)
- **ConsoleLogBackend** (`Sources/SimpleLogger/Backend/ConsoleBackend.swift`): Enhanced console output with configurable verbosity levels, stderr/stdout selection, ANSI colors, and proper Linux compatibility. Cross-platform compatible

### Key Design Patterns

1. **Protocol-Oriented Design**: LoggerManagerProtocol allows for easy testing and mocking
2. **Backend Strategy Pattern**: LoggerBackend protocol enables different output destinations
3. **Thread Safety**: Uses DispatchQueue for async logging operations
4. **Metadata Support**: File, function, and line number automatically captured and passed to backends
5. **Platform Adaptation**: `.default()` automatically uses OSLogBackend on Apple platforms, ConsoleLogBackend elsewhere

## Development Guidelines

### Creating New Backends

Implement `LoggerBackend` protocol with:
- `subsystem` and `category` properties
- `log(level:message:metadata:)` method
- Must be `Sendable` for thread safety

### Console Verbosity Levels

ConsoleLogBackend supports four verbosity levels (`ConsoleVerbosity`) and advanced output options:
- `.silent` - No output
- `.minimal` - Message only
- `.standard` - Timestamp, level, and message
- `.detailed` - Full metadata including file, function, and line number

Output Features:
- **stderr vs stdout**: Use `useStderr: true` for proper log separation (default: false for better test visibility)
- **ANSI Colors**: Use `enableColors: true` (default) for colored output on supporting terminals
- **Cross-platform**: Optimized buffering and flushing for Linux/Unix systems

Usage examples:
```swift
// Silent logger (no output)
let logger = LoggerManager.console(verbosity: .silent)

// Minimal output
let logger = LoggerManager.console(verbosity: .minimal)

// Standard output (default for .default() method)
let logger = LoggerManager.console(verbosity: .standard)

// Detailed output (default for .console() method)
let logger = LoggerManager.console(verbosity: .detailed)

// Custom environment key for disabling
let logger = LoggerManager(backend: ConsoleLogBackend(
    subsystem: "MyApp", 
    category: "Network", 
    verbosity: .standard,
    environmentKey: "DISABLE_NETWORK_LOGS"
))

// Linux-optimized logger with stderr and colors
let linuxLogger = LoggerManager.console(
    subsystem: "LinuxApp",
    category: "Service",
    verbosity: .standard,
    useStderr: true,      // Send logs to stderr (recommended for production)
    enableColors: true    // ANSI colors for better readability
)

// Production logger without colors
let prodLogger = LoggerManager(backend: ConsoleLogBackend(
    subsystem: "ProdApp",
    verbosity: .minimal,
    useStderr: true,
    enableColors: false   // No colors for log files
))

// Enhanced OSLog with fault-level warnings
let osLogger = LoggerManager(backend: OSLogBackend(
    subsystem: "com.myapp.critical",
    category: "security", 
    enhancedWarnings: true  // Maps warnings to .fault for better visibility
))
```

### Testing Patterns

Use the test pattern from `LoggerManagerTests.swift:23-28` for custom logger testing:
```swift
struct CustomLogger: LoggerManagerProtocol {
    let expect: @Sendable (String, LogLevel) -> Void
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        expect(message, level)
    }
}
```

### Environment Configuration

Both OSLogBackend and ConsoleLogBackend respect the `DisableLogger` environment variable (set to "true", "1", or "yes" to disable logging). You can also specify a custom environment key when creating backends.

## Cross-Platform Support

- **Apple Platforms**: Uses OSLogBackend with native unified logging
- **Linux and Other Platforms**: Automatically falls back to ConsoleLogBackend
- **Conditional Compilation**: OSLogBackend is wrapped in `#if canImport(OSLog)` for platform compatibility

## Swift Package Manager

This is a Swift Package with:
- Swift 6 language mode
- Cross-platform support (Apple platforms, Linux, and others)
- Testing framework: Swift Testing (not XCTest)
- No external dependencies