//
//  ------------------------------------------------
//  Original project: LoggerManager
//  Created on 2024/10/28 by Fatbobman(东坡肘子)
//  X: @fatbobman
//  Mastodon: @fatbobman@mastodon.social
//  GitHub: @fatbobman
//  Blog: https://fatbobman.com
//  ------------------------------------------------
//  Copyright © 2024-present Fatbobman. All rights reserved.

import Foundation
#if canImport(OSLog)
    import OSLog

    /// An implementation of the `LoggerBackend` protocol that logs messages to OSLog.
    @available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, visionOS 1.0, *)
    public final class OSLogBackend: LoggerBackend {
        /// The subsystem name
        public let subsystem: String
        /// The category name
        public let category: String
        /// A logger Instance
        let logger: Logger

        /// A boolean value that indicates whether the logger is enabled.
        let loggerEnabled: Bool
        
        /// Whether to use enhanced warning level mapping
        public let enhancedWarnings: Bool

        /// Initializes an `OSLogBackend` instance with the specified subsystem and category.
        ///
        /// - Parameters:
        ///   - subsystem: The subsystem name.
        ///   - category: The category name.
        ///   - enhancedWarnings: Whether to map warnings to .fault for better visibility (default: false for compatibility).
        ///   - environmentKey: The environment key to check for disabling the logger.
        public init(
            subsystem: String, 
            category: String, 
            enhancedWarnings: Bool = false,
            environmentKey: String = "DisableLogger"
        ) {
            // Input validation
            guard !subsystem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                fatalError("OSLogBackend: subsystem and category cannot be empty")
            }
            
            self.subsystem = subsystem
            self.category = category
            self.enhancedWarnings = enhancedWarnings
            logger = Logger(subsystem: subsystem, category: category)
            
            if let value = ProcessInfo.processInfo.environment[environmentKey]?.lowercased() {
                loggerEnabled = !(value == "true" || value == "1" || value == "yes")
            } else {
                loggerEnabled = true
            }
        }

        /// Logs a message with the specified level, message, and metadata.
        ///
        /// - Parameters:
        ///   - level: The log level.
        ///   - message: The message to log.
        ///   - metadata: The metadata to log.
        public func log(level: LogLevel, message: String, metadata: [String: String]?) {
            guard loggerEnabled else { return }
            
            let osLogType: OSLogType = switch level {
                case .debug: .debug
                case .info: .info
                case .warning: enhancedWarnings ? .fault : .default
                case .error: .error
            }
            
            // Note: OSLog automatically optimizes disabled log levels, so no need to check explicitly

            #if DEBUG
                let fullMessage = formatDebugMessage(message: message, metadata: metadata)
                // Privacy support is available since the class is already @available for iOS 14.0+
                logger.log(level: osLogType, "\(fullMessage, privacy: .public)")
            #else
                if level > .debug {
                    // Privacy support is available since the class is already @available for iOS 14.0+
                    logger.log(level: osLogType, "\(message, privacy: .public)")
                }
            #endif
        }
        
        /// Formats debug message with metadata
        private func formatDebugMessage(message: String, metadata: [String: String]?) -> String {
            guard let metadata = metadata else { return message }
            
            let function = metadata["function"] ?? ""
            let file = metadata["file"] ?? ""
            let line = metadata["line"] ?? ""
            
            return "\(message) in \(function) at \(file):\(line)"
        }
    }

#endif // canImport(OSLog)
