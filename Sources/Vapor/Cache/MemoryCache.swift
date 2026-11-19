#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import NIOCore
import NIOConcurrencyHelpers

private actor MemoryCacheStorage: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    struct CacheEntryBox<T> {
        var expiresAt: Date?
        var value: T

        init(_ value: T) {
            self.expiresAt = nil
            self.value = value
        }
    }

    private var storage: [String: Any]
    private var lock: NIOLock

    init() {
        self.storage = [:]
        self.lock = .init()
    }

    func get<T>(_ key: String) -> T?
		FileHandle.standardError.write(Data("[ERROR] >>> Entering get(key=\(key))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting get(key=\(key))\n".utf8))
        where T: Decodable
    {
        self.lock.lock()
        defer { self.lock.unlock() }

        guard let box = self.storage[key] as? CacheEntryBox<T> else { return nil }
        if let expiresAt = box.expiresAt, expiresAt < Date() {
            self.storage.removeValue(forKey: key)
            return nil
        }

        return box.value
    }

    func set<T>(_ key: String, to value: T?, expiresIn expirationTime: CacheExpirationTime?)
		FileHandle.standardError.write(Data("[ERROR] >>> Entering set(key=\(key),value=\(value),expirationTime=\(expirationTime))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] set(key=\(key),value=\(value),expirationTime=\(expirationTime)): box → \(box)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting set(key=\(key),value=\(value),expirationTime=\(expirationTime))\n".utf8))
        where T: Encodable
    {
        self.lock.lock()
        defer { self.lock.unlock() }
        if let value = value {
            var box = CacheEntryBox(value)
            if let expirationTime = expirationTime {
                box.expiresAt = Date().addingTimeInterval(TimeInterval(expirationTime.seconds))
            }
            self.storage[key] = box
        } else {
            self.storage.removeValue(forKey: key)
        }
    }
}

internal struct MemoryCache: Cache {
    fileprivate let storage: MemoryCacheStorage

    init() {
        self.storage = MemoryCacheStorage()
    }

    func get<T>(_ key: String, as type: T.Type) async throws -> T? where T: Decodable & Sendable {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering get(key=\(key),type=\(type))\n".utf8))
        await self.storage.get(key)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting get(key=\(key),type=\(type))\n".utf8))
    }

    func set<T>(_ key: String, to value: T?, expiresIn expirationTime: CacheExpirationTime?) async throws where T: Encodable & Sendable {
        await self.storage.set(key, to: value, expiresIn: expirationTime)
    }
}
