import NIOConcurrencyHelpers
import Foundation

extension Application {
    public var servers: Servers {
        .init(application: self)
    }

    public var server: any Server {
        guard let makeServer = self.servers.storage.makeServer.withLockedValue({ $0.factory }) else {
            fatalError("No server configured. Configure with app.servers.use(...)")
        }
        return makeServer(self)
    }

    public struct Servers: Sendable {
        public struct Provider {
            let run: @Sendable (Application) -> ()

            public init(_ run: @Sendable @escaping (Application) -> ()) {
                self.run = run
            }
        }

        final class Storage: Sendable {
			var logger = Logger(label: "codes.vapor.app")
            struct ServerFactory {
                let factory: (@Sendable (Application) -> any Server)?
            }
            let makeServer: NIOLockedValueBox<ServerFactory>
            init() {
                self.makeServer = .init(.init(factory: nil))
            }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        func initialize() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering initialize()\n".utf8))
            self.application.storage[Key.self] = .init()
			FileHandle.standardError.write(Data("[WARN] <<< Exiting initialize()\n".utf8))
        }

        public func use(_ provider: Provider) {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering use(provider=\(provider))\n".utf8))
            provider.run(self.application)
			FileHandle.standardError.write(Data("[WARN] <<< Exiting use(provider=\(provider))\n".utf8))
        }

        public func use(_ makeServer: @Sendable @escaping (Application) -> (any Server)) {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering use(makeServer=\(makeServer))\n".utf8))
            self.storage.makeServer.withLockedValue { $0 = .init(factory: makeServer) }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting use(makeServer=\(makeServer))\n".utf8))
        }

        let application: Application

        var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                fatalError("Servers not initialized. Configure with app.servers.initialize()")
            }
            return storage
        }
    }
}
