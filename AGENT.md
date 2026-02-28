# AGENT.md

This repository is a small Swift Package that provides a backend-agnostic logging API for Swift 6 projects.

## Project Summary

- Package name: `SimpleLogger`
- Module: `SimpleLogger`
- Minimum Swift tools version: 6.0
- Primary platforms: iOS 14+, macOS 11+, watchOS 7+, tvOS 14+, visionOS 1+
- Non-Apple platforms: Linux and other Unix-like systems
- Android support exists in the codebase through the console backend and remains experimental

## Architecture

- `LoggerManagerProtocol` is the public logging interface.
- `LoggerManager` is the default concrete implementation. It sends log work to a serial `DispatchQueue`.
- `LoggerBackend` is the pluggable backend protocol.
- `ConsoleLogBackend` writes formatted messages to stdout or stderr.
- `OSLogBackend` bridges to `OSLog` on supported Apple platforms.
- `MockLogBackend` is a DEBUG-only test helper that captures logs in memory.

## Current Behavior

- Logging through `LoggerManager` is asynchronous.
- `LoggerManagerProtocol.flush()` can be used to drain previously submitted log work.
- Metadata passed to backends includes `file`, `function`, and `line`.
- `LoggerManager.default(subsystem:category:useStderr:)` uses `OSLogBackend` when `OSLog` is available on supported Apple OS versions, and falls back to `ConsoleLogBackend(verbosity: .standard)` otherwise.
- The `useStderr` argument only affects the non-Apple console fallback path used by `LoggerManager.default(...)`.
- `ConsoleLogBackend` supports `silent`, `minimal`, `standard`, and `detailed` output modes.
- `ConsoleLogBackend` is the path used for Linux and Android-oriented support.
- Both built-in backends honor an environment key, defaulting to `DisableLogger`.
- `OSLogBackend` validates `subsystem` and `category` and traps on empty values.
- `MockLogBackend` uses `NSLock`, not `Synchronization.Mutex`.

## Platform Notes

- Apple platforms use `OSLogBackend` by default when available.
- Linux support is an active compatibility target and is covered by the GitHub Actions workflow.
- Android support is implemented through conditional handling in `ConsoleLogBackend`, especially around ANSI color behavior.
- When describing Android support, keep the wording experimental unless the repository adds stronger validation.

## Build And Test

```bash
swift build
swift test
swift test -q
```

## Formatting

- This repository uses Apple's `swift-format`.
- Configuration lives in `.swift-format`.
- The repo-managed Git hook lives in `.githooks/pre-commit`.
- Run `Scripts/install-hooks.sh` once per clone to set `core.hooksPath` to `.githooks`.

## Release And Tagging

- Use release tags in `x.x.x` format.
- Do not create new release tags with a `v` prefix.
- If release documentation mentions a version, keep it aligned with the latest `x.x.x` tag used by the repository.
- Prefer curated GitHub release notes over raw auto-generated notes.
- Keep release notes short and user-facing. Summarize the main API changes, platform/CI changes, tooling changes, and any notable documentation updates.
- When a release is not breaking, say so explicitly instead of implying a major migration.

## GitHub Actions

- CI workflow files:
  - `.github/workflows/linux-test.yml`
  - `.github/workflows/android-test.yml`
- Both workflows are triggered on pushes to `main` and `develop`, pull requests targeting `main`, and can be run manually.
- `linux-test.yml` runs on `ubuntu-latest` with the `swift:6.0` container.
- `android-test.yml` runs on `ubuntu-latest` and builds and runs Swift package tests on Android through `skiptools/swift-android-action`.
- Current CI coverage includes package build, full Linux test execution, Linux console backend scenarios, environment-variable behavior, `MockLogBackend` concurrency checks, and Android package test execution.

## Notes For Agents

- Do not describe the package as using `Synchronization.Mutex`; the current code uses `DispatchQueue` and `NSLock`.
- Do not show `ProcessInfo.processInfo.environment["DisableLogger"] = ...` as a working way to set environment variables at runtime.
- Do describe Linux and Android support, but keep Android wording experimental.
- Treat `.github/workflows/linux-test.yml` and `.github/workflows/android-test.yml` as the current CI source of truth for Linux and Android coverage.
- When documenting `LoggerManager.default(...)`, mention that `useStderr` only applies to the non-Apple console fallback path.
- When documenting `flush()`, describe it as a drain helper for queued async logs, not as a mode switch to synchronous logging.
- Use `x.x.x` for any new release-tag guidance.
- Remember that logging remains asynchronous by default even though `flush()` exists to drain queued work.
