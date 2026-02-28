# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.
For authoritative project details, architecture, build commands, platform notes, and agent rules, see **[AGENTS.md](./AGENTS.md)**.

## Claude-Specific Supplements

### Testing Patterns

For unit tests that need a lightweight custom logger, implement `LoggerManagerProtocol` directly (see `LoggerManagerTests.swift:23-28`):

```swift
struct CustomLogger: LoggerManagerProtocol {
    let expect: @Sendable (String, LogLevel) -> Void
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        expect(message, level)
    }
}
```

### Key Reminders

- Logging is **asynchronous**. Use `flush()` only to drain queued work before process exit or test teardown — it does not switch to synchronous mode.
- `useStderr` in `LoggerManager.default(...)` only affects the non-Apple console fallback path.
- Do not use `ProcessInfo.processInfo.environment[key] = ...` at runtime to toggle logging; environment variables must be set before process launch.
- `MockLogBackend` uses `NSLock`, not `Synchronization.Mutex`.
- `OSLogBackend` traps on empty `subsystem` or `category`.
- Android support is experimental.
