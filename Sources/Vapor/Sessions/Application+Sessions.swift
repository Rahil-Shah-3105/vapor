import NIOConcurrencyHelpers
import Foundation

extension Application {
    public var sessions: Sessions {
        .init(application: self)
    }

    public struct Sessions: Sendable {
        public struct Provider: Sendable {
            public static var memory: Self {
                .init {
                    $0.sessions.use { $0.sessions.memory }
                }
            }

            let run: @Sendable (Application) -> ()

            public init(_ run: @Sendable @escaping (Application) -> ()) {
                self.run = run
            }
        }

        final class Storage: Sendable {
			var logger = Logger(label: "codes.vapor.app")
            struct SessionDriverFactory {
                let factory: (@Sendable (Application) -> any SessionDriver)?
            }
            let memory: MemorySessions.Storage
            let makeDriver: NIOLockedValueBox<SessionDriverFactory>
            let configuration: NIOLockedValueBox<SessionsConfiguration>
            init() {
                self.memory = .init()
                self.configuration = .init(.default())
                self.makeDriver = .init(.init(factory: nil))
            }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        let application: Application

        public var configuration: SessionsConfiguration {
            get {
                self.storage.configuration.withLockedValue { $0 }
            }
            nonmutating set {
                self.storage.configuration.withLockedValue { $0 = newValue }
            }
        }

        public var middleware: SessionsMiddleware {
            .init(
                session: self.driver,
                configuration: self.configuration
            )
        }

        public var driver: any SessionDriver {
            guard let makeDriver = self.storage.makeDriver.withLockedValue({ $0.factory }) else {
                fatalError("No driver configured. Configure with app.sessions.use(...)")
            }
            return makeDriver(self.application)
        }

        public var memory: MemorySessions {
            .init(storage: self.storage.memory)
        }

        public func use(_ provider: Provider) {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering use(provider=\(provider))\n".utf8))
            provider.run(self.application)
			FileHandle.standardError.write(Data("[WARN] <<< Exiting use(provider=\(provider))\n".utf8))
        }

        public func use(_ makeDriver: @Sendable @escaping (Application) -> (any SessionDriver)) {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering use(makeDriver=\(makeDriver))\n".utf8))
            self.storage.makeDriver.withLockedValue { $0 = .init(factory: makeDriver) }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting use(makeDriver=\(makeDriver))\n".utf8))
        }

        var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                fatalError("Sessions not configured. Configure with app.sessions.initialize()")
            }
            return storage
        }

        func initialize() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering initialize()\n".utf8))
            self.application.storage[Key.self] = .init()
			FileHandle.standardError.write(Data("[WARN] <<< Exiting initialize()\n".utf8))
        }
    }
}
