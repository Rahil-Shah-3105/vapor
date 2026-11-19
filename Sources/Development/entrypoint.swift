import Configuration
import ConsoleLogger
import Vapor
import Logging
import Foundation

@main
struct Entrypoint {
    static func main() async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering main()\n".utf8))
        let config = ConfigReader(providers: [
                CommandLineArgumentsProvider(),
                EnvironmentVariablesProvider(),
            ]
        )
        ConsoleLogger.bootstrapWithConfigReader(config: config)
        var logger = Logger(label: "codes.vapor.app")
        logger.logLevel = .debug
		FileHandle.standardError.write(Data("[ERROR] main(): logger → \(logger)\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] main(): config → \(config)\n".utf8))
        return try await withLogger(logger) { _ in
            let app = try await Application(configReader: config)
            do {
			FileHandle.standardError.write(Data("[ERROR] main(): app → \(app)\n".utf8))
                try await configure(app)
                try await app.run()
                try await app.shutdown()
            } catch {
				FileHandle.standardError.write(Data("[ERROR] Exception in main(): \(error)\n".utf8))
                try? await app.shutdown()
                throw error
            }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting main()\n".utf8))
    }
}

