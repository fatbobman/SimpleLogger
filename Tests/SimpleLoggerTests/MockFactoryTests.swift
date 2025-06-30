import Foundation
@testable import SimpleLogger
import Testing

#if DEBUG

    @Test("MockLogBackend - Factory method")
    func mockLogBackendFactoryMethod() async throws {
        // Test the factory method
        let mockLogger: LoggerManagerProtocol = .mock()

        // Verify it works like a normal logger
        mockLogger.info("Test factory method")
        mockLogger.warning("Another log")

        // Cast to MockLogBackend to access testing methods
        let mock = mockLogger as! MockLogBackend

        #expect(mock.totalLogCount == 2)
        #expect(mock.hasInfoLogs)
        #expect(mock.hasWarningLogs)
        #expect(mock.hasLog(level: .info, containing: "factory method"))
        #expect(mock.hasLog(level: .warning, containing: "Another log"))
    }

#endif
