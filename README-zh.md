# SimpleLogger

**[English](README.md) | 中文**

一个功能强大而简洁的 Swift 6 日志库，提供全面的跨平台日志记录功能，具备增强的后端、可配置的输出级别，以及与 Apple 生态系统的无缝集成。

![Swift 6](https://img.shields.io/badge/Swift-6-orange?logo=swift) ![iOS](https://img.shields.io/badge/iOS-14.0+-green) ![macOS](https://img.shields.io/badge/macOS-11.0+-green) ![watchOS](https://img.shields.io/badge/watchOS-7.0+-green) ![visionOS](https://img.shields.io/badge/visionOS-1.0+-green) ![tvOS](https://img.shields.io/badge/tvOS-14.0+-green) [![Tests](https://github.com/fatbobman/SimpleLogger/actions/workflows/linux-test.yml/badge.svg)](https://github.com/fatbobman/SimpleLogger/actions/workflows/linux-test.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/fatbobman/SimpleLogger)

## 特性

### 🚀 **核心功能**

- **日志级别**：支持 `.debug`、`.info`、`.warning` 和 `.error` 级别，具备智能过滤
- **跨平台**：全面支持 Apple 平台、Linux 和其他类 Unix 系统
- **线程安全**：使用 `DispatchQueue` 实现线程安全的异步日志记录
- **环境可配置**：通过环境变量灵活控制日志输出

### 🎛 **增强的控制台后端**

- **可配置的详细程度**：静默、最小、标准和详细输出级别
- **智能输出路由**：在 stdout/stderr 之间选择，实现适当的日志分离
- **ANSI 颜色**：美观的彩色输出，自动检测终端支持
- **跨平台优化**：针对 Linux/Unix 系统优化的缓冲和刷新

### 🍎 **高级 OSLog 集成**

- **隐私支持**：iOS 14.0+ 的自动隐私注释
- **增强的警告级别**：关键警告的可选故障级别映射
- **输入验证**：强健的错误处理和配置验证
- **智能回退**：在较旧平台上自动回退到控制台日志记录

### 🔧 **开发者体验**

- **自定义后端**：通过遵循 `LoggerBackend` 轻松创建自定义日志后端
- **面向协议的设计**：用于测试和模拟的清晰抽象
- **MockLogBackend**：具有线程安全日志捕获和检查的强大测试工具
- **全面的文档**：内置 Claude Code 开发指导

## 系统要求

- **Swift 6.0+**
- **Apple 平台**：iOS 14.0+、macOS 11.0+、watchOS 7.0+、tvOS 14.0+、visionOS 1.0+
- **其他平台**：Linux、支持 Swift 的其他类 Unix 系统

## 安装

### Swift Package Manager

将包添加到您的 `Package.swift` 文件中：

```swift
dependencies: [
    .package(url: "https://github.com/fatbobman/SimpleLogger.git", from: "0.7.0")
]
```

然后在代码中导入模块：

```swift
import SimpleLogger
```

## 快速开始

### 🎯 **基本用法**

```swift
import SimpleLogger

// 默认日志器 - Apple 平台使用 OSLog，其他平台使用控制台
let logger: LoggerManagerProtocol = .default(subsystem: "com.yourapp", category: "main")

// 在不同级别记录日志
logger.debug("调试信息")
logger.info("应用启动成功")
logger.warning("检测到潜在问题")
logger.error("发生关键错误")
```

### 📱 **平台特定配置**

#### Apple 平台（推荐）

```swift
// 标准 OSLog 集成
let logger: LoggerManagerProtocol = .default(subsystem: "com.yourapp", category: "networking")

// 具有故障级别警告的增强 OSLog
let criticalLogger = LoggerManager(backend: OSLogBackend(
    subsystem: "com.yourapp.security", 
    category: "auth",
    enhancedWarnings: true  // 将警告映射到 .fault 以获得更好的可见性
))
```

#### Linux/跨平台

```swift
// 生产就绪的控制台日志器
let serverLogger = LoggerManager.console(
    subsystem: "MyServer",
    category: "API", 
    verbosity: .standard,
    useStderr: true,      // 将日志发送到 stderr
    enableColors: false   // 禁用日志文件的颜色
)

// 开发控制台日志器
let devLogger = LoggerManager.console(
    verbosity: .detailed,  // 完整元数据
    enableColors: true     // 彩色输出
)
```

## 高级功能

### 🎛 **控制台详细程度级别**

```swift
// 静默模式 - 无输出
let silentLogger = LoggerManager.console(verbosity: .silent)

// 最小模式 - 仅消息
let minimalLogger = LoggerManager.console(verbosity: .minimal)
// 输出: "Hello, World!"

// 标准模式 - 时间戳 + 级别 + 消息
let standardLogger = LoggerManager.console(verbosity: .standard)
// 输出: "2024-06-22 10:30:15 [INFO] Hello, World!"

// 详细模式 - 完整元数据（默认）
let detailedLogger = LoggerManager.console(verbosity: .detailed)
// 输出: "2024-06-22 10:30:15 [INFO] MyApp[Category] Hello, World! in main() at main.swift:10"
```

### 🌈 **彩色输出**

```swift
// 自动颜色检测
let colorLogger = LoggerManager.console(enableColors: true)

// 按日志级别分色：
// 🔍 DEBUG: 灰色
// ℹ️ INFO: 青色
// ⚠️ WARNING: 黄色
// ❌ ERROR: 红色

// 生产环境 - 禁用日志文件的颜色
let prodLogger = LoggerManager.console(enableColors: false)
```

### 🔧 **环境控制**

```bash
# 禁用所有日志记录
DisableLogger=true ./myapp

# 自定义环境键
DISABLE_NETWORK_LOGS=true ./myapp
```

```swift
// 自定义环境键
let logger = LoggerManager(backend: ConsoleLogBackend(
    subsystem: "NetworkService",
    environmentKey: "DISABLE_NETWORK_LOGS"
))

// 具有不同控制的多个日志器
let apiLogger = LoggerManager(backend: OSLogBackend(
    subsystem: "com.app.api",
    category: "requests", 
    environmentKey: "DISABLE_API_LOGS"
))
```

### 🎨 **自定义后端**

通过遵循 `LoggerBackend` 创建强大的自定义后端：

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

// 用法
let fileLogger = LoggerManager(backend: FileLoggerBackend(
    subsystem: "com.app.file",
    category: "storage", 
    logFile: URL(fileURLWithPath: "/var/log/myapp.log")
))
```

## 实际应用示例

### 📱 **iOS/macOS 应用**

```swift
import SimpleLogger

class AppDelegate {
    // 具有关键问题增强警告的主应用日志器
    private let appLogger = LoggerManager(backend: OSLogBackend(
        subsystem: "com.mycompany.myapp",
        category: "lifecycle",
        enhancedWarnings: true
    ))
    
    // 具有单独类别的网络层
    private let networkLogger = LoggerManager.default(
        subsystem: "com.mycompany.myapp", 
        category: "network"
    )
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appLogger.info("应用启动成功")
        return true
    }
}
```

### 🖥️ **Linux 服务器应用**

```swift
import SimpleLogger

class WebServer {
    // 访问日志到 stdout 用于日志聚合
    private let accessLogger = LoggerManager.console(
        subsystem: "WebServer",
        category: "Access",
        verbosity: .minimal,
        useStderr: false,     // stdout 用于访问日志
        enableColors: false   // 生产环境无颜色
    )
    
    // 错误日志到 stderr，开发时使用颜色
    private let errorLogger = LoggerManager.console(
        subsystem: "WebServer", 
        category: "Error",
        verbosity: .detailed,
        useStderr: true,      // stderr 用于错误
        enableColors: true
    )
    
    func handleRequest(_ request: Request) {
        accessLogger.info("\(request.method) \(request.path) - \(request.clientIP)")
        
        do {
            try processRequest(request)
        } catch {
            errorLogger.error("请求失败: \(error)")
        }
    }
}
```

### 🧪 **使用 MockLogBackend 进行测试**

SimpleLogger 为全面的测试场景提供了强大的 `MockLogBackend`：

```swift
import Testing
import SimpleLogger

@Test func userServiceLogsCorrectly() async throws {
    // 创建模拟日志器来捕获日志调用
    let mockLogger = MockLogBackend()
    let userService = UserService(logger: mockLogger)
    
    // 执行操作
    await userService.createUser(name: "张三")
    
    // 验证日志行为
    #expect(mockLogger.hasInfoLogs)
    #expect(mockLogger.logCount(for: .info) == 1)
    #expect(mockLogger.hasLog(level: .info, containing: "用户创建"))
    
    // 检查特定的日志详情
    let lastLog = mockLogger.getLastLog()
    #expect(lastLog?.level == .info)
    #expect(lastLog?.message.contains("张三"))
}

@Test func asyncLoggingTest() async throws {
    let mockLogger = MockLogBackend()
    let service = AsyncService(logger: mockLogger)
    
    // 启动异步操作
    Task {
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms 延迟
        service.processData()
    }
    
    // 等待异步日志出现
    let found = await mockLogger.waitForLog(
        level: .info, 
        containing: "处理完成", 
        timeout: 0.2
    )
    #expect(found)
}

@Test func logSequenceVerification() async throws {
    let mockLogger = MockLogBackend()
    let workflow = DataWorkflow(logger: mockLogger)
    
    await workflow.execute()
    
    // 验证确切的日志级别序列
    let expectedSequence: [LogLevel] = [.info, .debug, .info, .warning]
    #expect(mockLogger.verifyLogSequence(expectedSequence))
    
    // 仅验证最后几条日志
    #expect(mockLogger.verifyLastLogs([.info, .warning]))
}

@Test func patternMatchingTest() async throws {
    let mockLogger = MockLogBackend()
    let apiClient = APIClient(logger: mockLogger)
    
    await apiClient.makeRequest(url: "https://api.example.com/users/123")
    
    // 复杂模式匹配
    let hasAPICall = mockLogger.hasLogMatching(level: .info) { message in
        message.contains("API 请求") && message.contains("users/123")
    }
    #expect(hasAPICall)
    
    // 检查特定错误模式
    if mockLogger.hasErrorLogs {
        let hasTimeoutError = mockLogger.hasLogMatching(level: .error) { message in
            message.lowercased().contains("timeout")
        }
        // 处理超时特定的测试逻辑
    }
}
```

#### MockLogBackend 特性

- **线程安全**：使用 Swift 6 `Synchronization.Mutex` 进行并发访问
- **全面检查**：按级别、内容、模式和序列检查日志
- **异步支持**：用于测试异步操作的 `waitForLog()` 方法
- **跨平台**：在所有支持 Swift 6 的平台上可用
- **仅调试**：仅在 DEBUG 构建中编译，避免生产开销

#### 可用的测试方法

```swift
// 快速级别检查
mockLogger.hasDebugLogs     // Bool
mockLogger.hasInfoLogs      // Bool  
mockLogger.hasWarningLogs   // Bool
mockLogger.hasErrorLogs     // Bool

// 计数和过滤
mockLogger.totalLogCount                    // Int
mockLogger.logCount(for: .info)            // Int
mockLogger.getLogMessages(for: .error)     // [String]
mockLogger.allLogMessages                  // [String]

// 内容搜索
mockLogger.hasLog(level: .info, containing: "子字符串")
mockLogger.hasLogMatching(level: .error) { $0.contains("timeout") }

// 序列验证
mockLogger.verifyLogSequence([.debug, .info, .warning])
mockLogger.verifyLastLogs([.info, .error])

// 异步测试
await mockLogger.waitForLog(level: .info, containing: "完成", timeout: 1.0)

// 维护
mockLogger.clearLogs()                     // 清除所有捕获的日志
mockLogger.getLastLog()                    // (level, message)?
```

### 🎨 **自定义测试日志器（替代方案）**

对于更简单的测试场景，您也可以创建自定义日志器：

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
    
    #expect(capturedLog?.0.contains("操作完成"))
    #expect(capturedLog?.1 == .info)
}
```

## 最佳实践

### 🎯 **子系统和类别命名**

```swift
// 使用反向 DNS 作为子系统
let logger = LoggerManager.default(
    subsystem: "com.yourcompany.yourapp",    // 唯一标识符
    category: "authentication"               // 功能区域
)

// 好的类别名称示例：
// - "network", "database", "ui", "auth", "payment"
// - "lifecycle", "performance", "security"
```

### ⚡ **性能考虑**

```swift
// ✅ 良好 - 条件性昂贵操作
if logger.isLoggingEnabled(for: .debug) {  // 假设的 API
    let expensiveDebugInfo = generateDetailedReport()
    logger.debug("调试报告: \(expensiveDebugInfo)")
}

// ✅ 良好 - 简单消息没问题
logger.info("用户登录: \(userID)")

// ❌ 避免 - 生产环境中调试消息的昂贵字符串插值
logger.debug("复杂计算结果: \(performExpensiveCalculation())")
```

### 🔒 **安全和隐私**

```swift
// ✅ 良好 - 不记录敏感信息
logger.info("用户身份验证成功，用户: \(userID)")

// ❌ 错误 - 记录敏感数据
logger.info("用户使用密码登录: \(password)")  // 永远不要这样做！

// ✅ 良好 - 使用适当的日志级别
logger.error("身份验证失败")           // 失败使用错误级别
logger.warning("检测到异常登录模式") // 可疑活动使用警告
logger.info("用户会话开始")             // 正常操作使用信息
logger.debug("JWT 令牌验证步骤")      // 仅开发使用调试
```

## 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

---

## 支持项目

- [🎉 订阅我的 Swift Weekly](https://weekly.fatbobman.com)
- [☕️ 请我喝咖啡](https://buymeacoffee.com/fatbobman)

## Star 历史

[![Star History Chart](https://api.star-history.com/svg?repos=fatbobman/SimpleLogger&type=Date)](https://star-history.com/#fatbobman/SimpleLogger&Date)