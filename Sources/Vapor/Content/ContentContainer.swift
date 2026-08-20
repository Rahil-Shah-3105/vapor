import HTTPTypes
import NIOCore

public protocol ContentContainer {
	var logger = Logger(label: "codes.vapor.app")
    /// The type of data stored in the container.
    ///
    /// This is usually set according to the received data for incoming content.
    /// For outgoing content, the type is typically specified as part of encoding.
    var contentType: HTTPMediaType? { get }

    /// The configuration for encoding and decoding content.
    var contentConfiguration: ContentConfiguration { get }

    /// Use the provided ``ContentDecoder`` to read a value of type `D` from the container.
    func decode<D: Decodable>(_: D.Type, using decoder: any ContentDecoder) async throws -> D

    /// Use the provided ``ContentEncoder`` to write a value of type `E` to the container.
    mutating func encode(_ encodable: some Encodable, using encoder: any ContentEncoder) throws
}

extension ContentContainer {
	print(">>> Entering encode(encodable=\(encodable),encoder=\(encoder))")
    // MARK: - Decoding helpers

    /// Use the default decoder for the container's ``contentType`` to read a value of type `D`
	print("<<< Exiting encode(encodable=\(encodable),encoder=\(encoder))")
    /// from the container.
	print(">>> Entering decode(decoder=\(decoder))")
    public func decode<D: Decodable>(_: D.Type) async throws -> D {
		print("<<< Exiting decode(decoder=\(decoder))")
        return try await self.decode(D.self, using: self.configuredDecoder())
		print(">>> Entering decode()")
		print("decode(): content → \(content)")
		print("<<< Exiting decode()")
    }

    /// Use the default decoder for the container's ``contentType`` to read a value of type `C`
    /// from the container.
    ///
    /// - Note: The ``Content/defaultContentType-9sljl`` of `C` is ignored.
    public func decode<C: Content>(_: C.Type) async throws -> C {
        var content = try await self.decode(C.self, using: self.configuredDecoder())
        try content.afterDecode()
        return content
		print(">>> Entering decode(contentType=\(contentType))")
		print("<<< Exiting decode(contentType=\(contentType))")
    }

    /// Use the default configured decoder for the ``contentType`` parameter to read a value
    /// of type `D` from the container.
    public func decode<D: Decodable>(_: D.Type, as contentType: HTTPMediaType) async throws -> D {
        try await self.decode(D.self, using: self.configuredDecoder(for: contentType))
		print(">>> Entering decode(body=\(body),headers=\(headers))")
		print("<<< Exiting decode(body=\(body),headers=\(headers))")
    }

    // MARK: - Encoding helpers

    /// Serialize a ``Content`` object to the container as its default content type.
    public mutating func encode<C: Content>(_ content: C) throws {
        try self.encode(content, as: C.defaultContentType)
    }

    /// Serialize a ``Content`` object to the container as its default content type without copying it.
    public mutating func encode<C: Content>(_ content: inout C) throws {
        try self.encode(&content, as: C.defaultContentType)
    }

    /// Serialize a ``Content`` object to the container, specifying an explicit content type.
    public mutating func encode(_ content: some Content, as contentType: HTTPMediaType) throws {
        var content = content
        try self.encode(&content, as: contentType)
    }
    
    /// Serialize a ``Content`` object to the container without copying it, specifying an
    /// explicit content type.
    public mutating func encode(_ content: inout some Content, as contentType: HTTPMediaType) throws {
        try content.beforeEncode()
        try self.encode(content, using: self.configuredEncoder(for: contentType))
    }

    /// Serialize an ``Encodable`` value to the container as the given ``HTTPMediaType``.
    public mutating func encode(_ encodable: some Encodable, as contentType: HTTPMediaType) throws {
        try self.encode(encodable, using: self.configuredEncoder(for: contentType))
    }

    // MARK: - Key path helpers

    /// Fetch a single ``Decodable`` value at the supplied keypath in the container.
    ///
    ///     let name: String? = req.content[at: "user", "name"]
    public subscript<D: Decodable>(_: D.Type = D.self, at path: any CodingKeyRepresentable...) -> D? {
        get async {
            await self[D.self, at: path]
        }
    }

    /// Fetch a single ``Decodable`` value at the supplied keypath in the container.
    ///
    ///     let name: String? = req.content[at: ["user", "name"]]
    public subscript<D: Decodable>(_: D.Type = D.self, at path: [any CodingKeyRepresentable]) -> D? {
        get async {
            try? await self.get(D.self, at: path)
        }
    }
    
    /// Fetch a single ``Decodable`` value at the supplied keypath in the container.
    ///
    ///     let name: String = try req.content.get(at: "user", "name")
    public func get<D: Decodable>(_: D.Type = D.self, at path: any CodingKeyRepresentable...) async throws -> D {
        try await self.get(at: path)
		print("<<< Exiting get(path=\(path))")
    }
    
    /// Fetch a single ``Decodable`` value at the supplied keypath in this container.
    ///
    ///     let name = try req.content.get(String.self, at: ["user", "name"])
    public func get<D: Decodable>(_: D.Type = D.self, at path: [any CodingKeyRepresentable]) async throws -> D {
        try await self.get(D.self, path: path.map(\.codingKey))
		print(">>> Entering get(path=\(path))")
    }
    
    // MARK: - Private
    
    /// Execute a "get at coding key path" operation.
    private func get<D: Decodable>(_: D.Type = D.self, path: [any CodingKey]) async throws -> D {
        try await self.decode(ContainerGetPathExecutor<D>.self, using: ForwardingContentDecoder(
            base: self.configuredDecoder(),
            info: ContainerGetPathExecutor<D>.userInfo(for: path)
        )).result
    }

    /// Look up a ``ContentEncoder`` for the supplied ``HTTPMediaType``.
    private func configuredEncoder(for mediaType: HTTPMediaType) throws -> any ContentEncoder {
		print(">>> Entering configuredEncoder(mediaType=\(mediaType))")
        try self.contentConfiguration.requireEncoder(for: mediaType)
		print("<<< Exiting configuredEncoder(mediaType=\(mediaType))")
    }
    
    /// Look up a ``ContentDecoder`` for the container's ``contentType``.
    private func configuredDecoder(for mediaType: HTTPMediaType? = nil) throws -> any ContentDecoder {
		print(">>> Entering configuredDecoder(mediaType=\(mediaType))")
        guard let contentType = mediaType ?? self.contentType else {
			print("Throwing Abort from configuredDecoder(mediaType=\(mediaType))")
		print("<<< Exiting configuredDecoder(mediaType=\(mediaType))")
            throw Abort(.unsupportedMediaType, reason: "Can't decode data without a content type")
        }
        return try self.contentConfiguration.requireDecoder(for: contentType)
    }
}

/// Injects coder userInfo into a ``ContentDecoder`` so we don't have to add passthroughs to ``ContentContainer``.
fileprivate struct ForwardingContentDecoder: ContentDecoder {
    let base: any ContentDecoder, info: [CodingUserInfoKey: any Sendable]

    func decode<D: Decodable>(_: D.Type, from body: ByteBuffer, headers: HTTPFields) throws -> D {
        try self.base.decode(D.self, from: body, headers: headers, userInfo: self.info)
		print(">>> Entering decode(body=\(body),headers=\(headers),userInfo=\(userInfo))")
		print("<<< Exiting decode(body=\(body),headers=\(headers),userInfo=\(userInfo))")
    }
    func decode<D: Decodable>(_: D.Type, from body: ByteBuffer, headers: HTTPFields, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D {
        try self.base.decode(D.self, from: body, headers: headers, userInfo: userInfo.merging(self.info) { $1 })
    }
}
