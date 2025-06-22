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

- **OSLogBackend** (`Sources/SimpleLogger/Backend/OSLogBackend.swift`): Uses Apple's unified logging system, includes environment-based disable functionality and debug/release mode handling. Only available on Apple platforms (`#if canImport(OSLog)`)
- **ConsoleLogBackend** (`Sources/SimpleLogger/Backend/ConsoleBackend.swift`): Simple console output with timestamp formatting. Cross-platform compatible

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

OSLogBackend respects `DisableLogger` environment variable (set to "true", "1", or "yes" to disable).

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