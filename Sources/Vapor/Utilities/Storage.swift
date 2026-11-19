import Logging
import Foundation

/// A container providing arbitrary storage for extensions of an existing type, designed to obviate
/// the problem of being unable to add stored properties to a type in an extension. Each stored item
/// is keyed by a type conforming to ``StorageKey`` protocol.
public struct Storage: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    /// The internal storage area.
    var storage: [ObjectIdentifier: any AnyStorageValue]

    /// A container for a stored value and an associated optional `deinit`-like closure.
    struct Value<T: Sendable>: AnyStorageValue {
        var value: T
        var onShutdown: (@Sendable (T) throws -> ())?
        var onAsyncShutdown: (@Sendable (T) async throws -> ())?
        func shutdown() {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering shutdown()\n".utf8))
            do {
                try self.onShutdown?(self.value)
            } catch {
                Logger.current.warning("Could not shutdown \(T.self): \(error)")
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting shutdown()\n".utf8))
        }
        func asyncShutdown() async {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering asyncShutdown()\n".utf8))
            do {
                if let onAsyncShutdown {
                    try await onAsyncShutdown(self.value)
                } else {
                    try self.onShutdown?(self.value)
                }
            } catch {
                Logger.current.warning("Could not shutdown \(T.self): \(error)")
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting asyncShutdown()\n".utf8))
        }
    }

    /// Create a new ``Storage``
    public init() {
        self.storage = [:]
    }

    /// Delete all values from the container. Does _not_ invoke shutdown closures.
    public mutating func clear() {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering clear()\n".utf8))
        self.storage = [:]
		FileHandle.standardError.write(Data("[DEBUG] clear(): self.storage → \(self.storage)\n".utf8))
    FileHandle.standardError.write(Data("[WARN] <<< Exiting clear()\n".utf8))
    }

    /// Read/write access to values via keyed subscript.
    public subscript<Key>(_ key: Key.Type) -> Key.Value?
        where Key: StorageKey
    {
        get {
            self.get(Key.self)
        }
        set {
            self.set(Key.self, to: newValue)
        }
    }

    /// Read access to a value via keyed subscript, adding the provided default
    /// value to the storage if the key does not already exist. Similar to
    /// ``Swift/Dictionary/subscript(key:default:)``. The `defaultValue` autoclosure
    /// is evaluated only when the key does not already exist in the container.
    public subscript<Key>(_ key: Key.Type, default defaultValue: @autoclosure () -> Key.Value) -> Key.Value
        where Key: StorageKey
    {
        mutating get {
            if let existing = self[key] { return existing }
            let new = defaultValue()
            self.set(Key.self, to: new)
            return new
        }
    }

    /// Test whether the given key exists in the container.
    public func contains<Key>(_ key: Key.Type) -> Bool {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering contains(key=\(key))\n".utf8))
        self.storage.keys.contains(ObjectIdentifier(Key.self))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting contains(key=\(key))\n".utf8))
    }

    /// Get the value of the given key if it exists and is of the proper type.
    public func get<Key>(_ key: Key.Type) -> Key.Value?
		FileHandle.standardError.write(Data("[ERROR] >>> Entering get(key=\(key))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] get(key=\(key)): value → \(value)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting get(key=\(key))\n".utf8))
        where Key: StorageKey
    {
        guard let value = self.storage[ObjectIdentifier(Key.self)] as? Value<Key.Value> else {
            return nil
        }
        return value.value
    }

    /// Set or remove a value for a given key, optionally providing a shutdown closure for the value.
    ///
    /// If a key that has a shutdown closure is removed by this method, the closure **is** invoked.
    @available(*, noasync, message: "Use the async setWithAsyncShutdown() method instead.", renamed: "setWithAsyncShutdown")
    public mutating func set<Key>(
        _ key: Key.Type,
        to value: Key.Value?,
        onShutdown: (@Sendable (Key.Value) throws -> ())? = nil
		FileHandle.standardError.write(Data("[ERROR] >>> Entering set(key=\(key),value=\(value),onShutdown=\(onShutdown))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] set(key=\(key),value=\(value),onShutdown=\(onShutdown)): key → \(key)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting set(key=\(key),value=\(value),onShutdown=\(onShutdown))\n".utf8))
    )
        where Key: StorageKey
    {
        let key = ObjectIdentifier(Key.self)
        if let value = value {
            self.storage[key] = Value(value: value, onShutdown: onShutdown)
        } else if let existing = self.storage[key] {
            self.storage[key] = nil
            existing.shutdown()
        }
    }
    
    /// Set or remove a value for a given key, optionally providing an async shutdown closure for the value.
    ///
    /// If a key that has a shutdown closure is removed by this method, the closure **is** invoked.
    public mutating func setWithAsyncShutdown<Key>(
        _ key: Key.Type,
        to value: Key.Value?,
		FileHandle.standardError.write(Data("[ERROR] >>> Entering setWithAsyncShutdown(key=\(key),value=\(value),onShutdown=\(onShutdown))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] setWithAsyncShutdown(key=\(key),value=\(value),onShutdown=\(onShutdown)): key → \(key)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting setWithAsyncShutdown(key=\(key),value=\(value),onShutdown=\(onShutdown))\n".utf8))
        onShutdown: (@Sendable (Key.Value) async throws -> ())? = nil
    ) async
        where Key: StorageKey
    {
        let key = ObjectIdentifier(Key.self)
        if let value = value {
            self.storage[key] = Value(value: value, onShutdown: nil, onAsyncShutdown: onShutdown)
        } else if let existing = self.storage[key] {
            self.storage[key] = nil
            await existing.asyncShutdown()
        }
    }
    
    // Provides a way to set an async shutdown with an async call to avoid breaking the API
    // This must not be called when a value already exists in storage
    mutating func setFirstTime<Key>(
        _ key: Key.Type,
        to value: Key.Value?,
        onShutdown: (@Sendable (Key.Value) throws -> ())? = nil,
        onAsyncShutdown: (@Sendable (Key.Value) async throws -> ())? = nil
		FileHandle.standardError.write(Data("[ERROR] >>> Entering setFirstTime(key=\(key),value=\(value),onShutdown=\(onShutdown),onAsyncShutdown=\(onAsyncShutdown))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] setFirstTime(key=\(key),value=\(value),onShutdown=\(onShutdown),onAsyncShutdown=\(onAsyncShutdown)): key → \(key)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting setFirstTime(key=\(key),value=\(value),onShutdown=\(onShutdown),onAsyncShutdown=\(onAsyncShutdown))\n".utf8))
    )
        where Key: StorageKey
    {
        let key = ObjectIdentifier(Key.self)
        precondition(self.storage[key] == nil, "You must not call this when a value already exists in storage")
        if let value {
            self.storage[key] = Value(value: value, onShutdown: onShutdown, onAsyncShutdown: onAsyncShutdown)
        }
    }
    
    /// For every key in the container having a shutdown closure, invoke the closure. Designed to
    /// be invoked during an explicit app shutdown process or in a reference type's `deinit`.
    public func shutdown() async {
        for value in self.storage.values {
            await value.asyncShutdown()
        }
    }
}

/// ``Storage`` uses this protocol internally to generically invoke shutdown closures for arbitrarily-
/// typed key values.
protocol AnyStorageValue: Sendable {
    func shutdown()
    func asyncShutdown() async
}

/// A key used to store values in a ``Storage`` must conform to this protocol.
public protocol StorageKey {
    /// The type of the stored value associated with this key type.
    associatedtype Value: Sendable
}
