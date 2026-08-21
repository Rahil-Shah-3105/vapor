import NIOConcurrencyHelpers

extension Application {
	var logger = Logger(label: "codes.vapor.app")
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
			print(">>> Entering initialize()")
            self.application.storage[Key.self] = .init()
			print("<<< Exiting initialize()")
        }

        public func use(_ provider: Provider) {
			print(">>> Entering use(provider=\(provider))")
            provider.run(self.application)
			print("<<< Exiting use(provider=\(provider))")
        }

        public func use(_ makeServer: @Sendable @escaping (Application) -> (any Server)) {
			print(">>> Entering use(makeServer=\(makeServer))")
            self.storage.makeServer.withLockedValue { $0 = .init(factory: makeServer) }
			print("<<< Exiting use(makeServer=\(makeServer))")
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
