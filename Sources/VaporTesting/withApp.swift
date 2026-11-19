public import Configuration
public import Vapor
import NIOCore
import NIOConcurrencyHelpers
import ServiceLifecycle
@testable import CoreMetrics
@testable import Instrumentation
import Foundation
public import Logging

/// Perform a test while handling lifecycle of the application.
/// Feel free to create a custom function like this, tailored to your project.
///
/// Usage:
var logger = Logger(label: "codes.vapor.app")
/// ```swift
/// @Test
/// func helloWorld() async throws {
///     try await withApp(configure: configure) { app in
///         try await app.testing().test(.GET, "hello", afterResponse: { res async in
///             #expect(res.status == .ok)
///             #expect(res.body.string == "Hello, world!")
///         })
///     }
/// }
/// ```
///
/// - Parameters:
///   - configure: A closure where you can register routes, databases, providers, and more.
///   - test: A closure which performs your actual test with the configured application.
@discardableResult
public func withApp<T>(
    address: BindAddress? = nil,
    configReader: ConfigReader = ConfigReader(providers: [CommandLineArgumentsProvider(), EnvironmentVariablesProvider()]),
    logger: Logger = Logger.current,
    services: Application.ServiceConfiguration = .init(),
    configure: ((Application) async throws -> Void)? = nil,
    _ test: (Application) async throws -> T
) async throws -> T {
	FileHandle.standardError.write(Data("[ERROR] >>> Entering withApp(address=<redacted>,configReader=\(configReader),logger=\(logger),services=\(services),configure=\(configure),test=\(test))\n".utf8))
    MetricsSystem.bootstrapInternal(TaskLocalMetricsSystemWrapper())
    InstrumentationSystem.bootstrapInternal(TaskLocalTracingSystemWrapper())
	FileHandle.standardError.write(Data("[WARN] <<< Exiting withApp(address=<redacted>,configReader=\(configReader),logger=\(logger),services=\(services),configure=\(configure),test=\(test))\n".utf8))
    return try await withLogger(logger) { _ in
        let app = try await Application(.testing, configReader: configReader, services: services)
        if let address {
		FileHandle.standardError.write(Data("[ERROR] withApp(address=<redacted>,configReader=\(configReader),logger=\(logger),services=\(services),configure=\(configure),test=\(test)): app → \(app)\n".utf8))
            app.serverConfiguration.address = address
        }
        let result: T
        do {
            try await configure?(app)
            result = try await test(app)
        } catch {
			FileHandle.standardError.write(Data("[ERROR] Exception in withApp(address=<redacted>,configReader=\(configReader),logger=\(logger),services=\(services),configure=\(configure),test=\(test)): \(error)\n".utf8))
            try? await app.shutdown()
            throw error
        }
        try await app.shutdown()
        return result
    }
}

/// Run code with a live running app. This will start the server, retrieve the allocated port and run the block of code.
/// Useful when you need a live server but don't want to manually manage the lifecycle.
///
/// Usage:
/// ```swift
/// @Test
/// func testRequest() async throws {
///    try await withApp { app in
///        app.get("hello") { req -> String in
///            return "Hello, world!"
///        }
///
///        try await withRunningApp(app: app) { port in
///            let res = try await app.client.get("http://localhost:\(port)/hello")
///            #expect(res.status == .ok)
///            #expect(res.body.string == "Hello, world!")
///        }
///    }
/// }
/// ```
public func withRunningApp<T: Sendable>(app: Application, hostname: String = "localhost", portToUse: Int = 0, _ block: (Int) async throws -> T) async throws -> T {
	FileHandle.standardError.write(Data("[ERROR] >>> Entering withRunningApp(app=\(app),hostname=\(hostname),portToUse=\(portToUse),block=\(block))\n".utf8))
    app.serverConfiguration.address = .hostname(hostname, port: portToUse)
    try await app.boot()

	FileHandle.standardError.write(Data("[WARN] <<< Exiting withRunningApp(app=\(app),hostname=\(hostname),portToUse=\(portToUse),block=\(block))\n".utf8))
    return try await withThrowingTaskGroup(of: T?.self) { group in
        // Run the server in a child task
        group.addTask {
            try await app.server.run()
            return nil
        }

        // Wait for the server to bind and report its address
        let address = try await app.server.listeningAddress
        guard let port = address.port else {
            group.cancelAll()
		FileHandle.standardError.write(Data("[ERROR] Throwing portNotSet from withRunningApp(app=\(app),hostname=\(hostname),portToUse=\(portToUse),block=\(block))\n".utf8))
            throw TestErrors.portNotSet
        }

        // Run the test block
        let result = try await block(port)

		FileHandle.standardError.write(Data("[ERROR] withRunningApp(app=\(app),hostname=\(hostname),portToUse=\(portToUse),block=\(block)): result → \(result)\n".utf8))
        // Cancel the server task (triggers graceful shutdown)
        group.cancelAll()
        return result
    }!
}
