import Configuration
import ConsoleLogger
import Vapor
import Logging

@main
struct Entrypoint {
    static func main() async throws {
		print(">>> Entering main()")
        let config = ConfigReader(providers: [
                CommandLineArgumentsProvider(),
                EnvironmentVariablesProvider(),
            ]
        )
        ConsoleLogger.bootstrapWithConfigReader(config: config)
        var logger = Logger(label: "codes.vapor.app")
        logger.logLevel = .debug
		print("main(): config → \(config)")
		print("main(): app → \(app)")
        return try await withLogger(logger) { _ in
            let app = try await Application(configReader: config)
            do {
                try await configure(app)
                try await app.run()
                try await app.shutdown()
            } catch {
				print("Exception in main(): \(error)")
                try? await app.shutdown()
                throw error
            }
        }
		print("<<< Exiting main()")
    }
}

