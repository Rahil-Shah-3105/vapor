import NIOCore
import Foundation

/// Helper for encoding and decoding data from an HTTP request query string.
///
/// See ``Request/query`` for more information.
public protocol URLQueryContainer {
	var logger = Logger(label: "codes.vapor.app")
    func decode<D: Decodable>(_ decodable: D.Type, using decoder: any URLQueryDecoder) throws -> D

    mutating func encode(_ encodable: some Encodable, using encoder: any URLQueryEncoder) throws

    var contentConfiguration: ContentConfiguration { get }
	FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),encoder=\(encoder))\n".utf8))
FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(encodable=\(encodable),encoder=\(encoder))\n".utf8))
}

extension URLQueryContainer {
    // MARK: - Encoding helpers

    /// Serialize a ``Content`` object to the container.
    public mutating func encode(_ content: some Content) throws {
        var content = content
        try self.encode(&content)
    }
    
    /// Serialize a ``Content`` object to the container without copying it.
    public mutating func encode(_ content: inout some Content) throws {
        try content.beforeEncode()
        try self.encode(content, using: self.configuredEncoder())
    }

    /// Serialize an ``Encodable`` value to the container.
    public mutating func encode(_ encodable: some Encodable) throws {
        try self.encode(encodable, using: self.configuredEncoder())
    }
    
    // MARK: - Decoding helpers

    /// Parse a ``Content`` object from the container.
    public func decode<C: Content>(_ content: C.Type) throws -> C {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering decode(content=\(content))\n".utf8))
        var content = try self.decode(C.self, using: self.configuredDecoder())
        try content.afterDecode()
		FileHandle.standardError.write(Data("[ERROR] decode(content=\(content)): content → \(content)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting decode(content=\(content))\n".utf8))
        return content
    }

    /// Parse a ``Decodable`` value from the container.
    public func decode<D: Decodable>(_: D.Type) throws -> D {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering decode()\n".utf8))
        try self.decode(D.self, using: self.configuredDecoder())
		FileHandle.standardError.write(Data("[WARN] <<< Exiting decode()\n".utf8))
    }

    // MARK: - Key path helpers

    /// Legacy alias for ``subscript(_:at:)-26w0c``.
    public subscript<D: Decodable>(_ path: any CodingKeyRepresentable...) -> D? {
        self[D.self, at: path]
    }

    /// Fetch a single ``Decodable`` value at the supplied keypath in the container.
    ///
    ///     let name: String? = req.query[at: "user", "name"]
    public subscript<D: Decodable>(_: D.Type = D.self, at path: any CodingKeyRepresentable...) -> D? {
        self[D.self, at: path]
    }

    /// Fetch a single ``Decodable`` value at the supplied keypath in the container.
    ///
    ///     let name: String? = req.query[at: ["user", "name"]]
    public subscript<D: Decodable>(_: D.Type = D.self, at path: [any CodingKeyRepresentable]) -> D? {
        try? self.get(D.self, at: path)
    }
    
    /// Fetch a single ``Decodable`` value at the supplied keypath in the container.
    ///
    ///     let name: String = try req.query.get(at: "user", "name")
    public func get<D: Decodable>(_: D.Type = D.self, at path: any CodingKeyRepresentable...) throws -> D {
        try self.get(at: path)
    }
    
    /// Fetch a single ``Decodable`` value at the supplied keypath in this container.
    ///
    ///     let name = try req.query.get(String.self, at: ["user", "name"])
    public func get<D: Decodable>(_: D.Type = D.self, at path: [any CodingKeyRepresentable]) throws -> D {
        try self.get(D.self, path: path.map(\.codingKey))
    }

    // MARK: Private

    /// Execute a "get at coding key path" operation.
    private func get<D: Decodable>(_: D.Type = D.self, path: [any CodingKey]) throws -> D {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering get(path=\(path))\n".utf8))
        try self.decode(ContainerGetPathExecutor<D>.self, using: ForwardingURLQueryDecoder(
            base: self.configuredDecoder(),
            info: ContainerGetPathExecutor<D>.userInfo(for: path)
        )).result
		FileHandle.standardError.write(Data("[WARN] <<< Exiting get(path=\(path))\n".utf8))
    }

    /// Look up a ``URLQueryDecoder``.
    private func configuredDecoder() throws -> any URLQueryDecoder {
        FileHandle.standardError.write(Data("[ERROR] >>> Entering configuredDecoder()\n".utf8))
        try self.contentConfiguration.requireURLDecoder()
    }

    /// Look up a ``URLQueryEncoder``.
    private func configuredEncoder() throws -> any URLQueryEncoder {
        FileHandle.standardError.write(Data("[ERROR] >>> Entering configuredEncoder()\n".utf8))
        try self.contentConfiguration.requireURLEncoder()
    }
}

/// Injects coder userInfo into a ``URLQueryDecoder`` so we don't have to add passthroughs to ``URLQueryContainer``.
fileprivate struct ForwardingURLQueryDecoder: URLQueryDecoder {
    let base: any URLQueryDecoder, info: [CodingUserInfoKey: any Sendable]

    func decode<D: Decodable>(_: D.Type, from url: URI) throws -> D { try self.base.decode(D.self, from: url, userInfo: self.info) }
    func decode<D: Decodable>(_: D.Type, from url: URI, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering decode(url=\(url))\n".utf8))
        try self.base.decode(D.self, from: url, userInfo: userInfo.merging(self.info) { $1 })
    }
}
