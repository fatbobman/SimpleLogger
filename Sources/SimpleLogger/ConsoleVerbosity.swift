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

/// An enumeration that defines the console output verbosity levels.
public enum ConsoleVerbosity: Sendable {
    /// Silent mode - no output
    case silent
    /// Minimal output - only message
    case minimal
    /// Standard output - message with level and timestamp
    case standard
    /// Detailed output - includes all metadata (file, function, line)
    case detailed
}