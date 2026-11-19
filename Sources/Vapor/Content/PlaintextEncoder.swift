#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
#warning("Make this internal")
public import NIOCore
public import HTTPTypes

/// Encodes data as plaintext, utf8.
public struct PlaintextEncoder: ContentEncoder {
    /// The specific plaintext `HTTPMediaType` to use.
    private let contentType: HTTPMediaType

    /// Creates a new `PlaintextEncoder`.
    ///
    /// - parameters:
    ///     - contentType: Plaintext `HTTPMediaType` to use. Usually `.plainText` or `.html`.
    public init(_ contentType: HTTPMediaType = .plainText) {
        self.contentType = contentType
    }

    // See `ContentEncoder.encode(_:to:headers:)`.
    public func encode(_ encodable: some Encodable, to body: inout ByteBuffer, headers: inout HTTPFields) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),body=\(body),headers=\(headers))\n".utf8))
        try self.encode(encodable, to: &body, headers: &headers, userInfo: [:])
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encode()\n".utf8))
    FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(forKey=\(forKey))\n".utf8))
    }

    // See `ContentEncoder.encode(_:to:headers:userInfo:)`.
    public func encode(_ encodable: some Encodable, to body: inout ByteBuffer, headers: inout HTTPFields, userInfo: [CodingUserInfoKey: any Sendable]) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo))\n".utf8))
        let encoder = _PlaintextEncoder(userInfo: userInfo)
        var container = encoder.singleValueContainer()
        try container.encode(encodable)
		FileHandle.standardError.write(Data("[ERROR] encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): container → \(container)\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): encoder → \(encoder)\n".utf8))

		FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(encodable=\(encodable),body=\(body),headers=\(headers))\n".utf8))
        guard let string = encoder.plaintext else {
		FileHandle.standardError.write(Data("[ERROR] Throwing invalidValue from encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo))\n".utf8))
            throw EncodingError.invalidValue(encodable, .init(codingPath: [], debugDescription: "Nothing was encoded!"))
        }
        headers.contentType = self.contentType
		FileHandle.standardError.write(Data("[DEBUG] encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): headers.contentType → \(headers.contentType)\n".utf8))
        body.writeString(string)
    }
}

// MARK: Private

private final class _PlaintextEncoder: Encoder, SingleValueEncodingContainer {
	var logger = Logger(label: "codes.vapor.app")
    let codingPath: [any CodingKey] = []
    let userInfoSendable: [CodingUserInfoKey: any Sendable]
    var userInfo: [CodingUserInfoKey: Any] { self.userInfoSendable }
    private(set) var plaintext: String?

    init(userInfo: [CodingUserInfoKey: any Sendable] = [:]) {
        self.userInfoSendable = userInfo
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        FileHandle.standardError.write(Data("[ERROR] >>> Entering container(type=\(type))\n".utf8))
        .init(FailureEncoder<Key>())
		FileHandle.standardError.write(Data("[WARN] <<< Exiting container(type=\(type))\n".utf8))
    }
    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        FileHandle.standardError.write(Data("[ERROR] >>> Entering unkeyedContainer()\n".utf8))
        FailureEncoder()
		FileHandle.standardError.write(Data("[WARN] <<< Exiting unkeyedContainer()\n".utf8))
    }
    func singleValueContainer() -> any SingleValueEncodingContainer {
        FileHandle.standardError.write(Data("[ERROR] >>> Entering singleValueContainer()\n".utf8))
        self
		FileHandle.standardError.write(Data("[WARN] <<< Exiting singleValueContainer()\n".utf8))
    }

    func encodeNil() throws {
        FileHandle.standardError.write(Data("[ERROR] >>> Entering encodeNil()\n".utf8))
        self.plaintext = nil
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encodeNil()\n".utf8))
    }

    // N.B.: Implementing the individual "primitive" coding methods on a container rather than forwarding through
    // each type's Codable implementation yields substantial speedups.
    func encode(_ value: Bool) throws { self.plaintext = value.description }
    func encode(_ value: Int) throws { self.plaintext = value.description }
    func encode(_ value: Double) throws { self.plaintext = value.description }
    func encode(_ value: String) throws { self.plaintext = value }
    func encode(_ value: Int8) throws { self.plaintext = value.description }
    func encode(_ value: Int16) throws { self.plaintext = value.description }
    func encode(_ value: Int32) throws { self.plaintext = value.description }
    func encode(_ value: Int64) throws { self.plaintext = value.description }
    func encode(_ value: UInt) throws { self.plaintext = value.description }
    func encode(_ value: UInt8) throws { self.plaintext = value.description }
    func encode(_ value: UInt16) throws { self.plaintext = value.description }
    func encode(_ value: UInt32) throws { self.plaintext = value.description }
    func encode(_ value: UInt64) throws { self.plaintext = value.description }
    func encode(_ value: Float) throws { self.plaintext = value.description }

    func encode(_ value: some Encodable) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(value=\(value))\n".utf8))
        if let data = value as? Data {
            // special case for data
            if let utf8 = String(validating: data, as: UTF8.self) {
                self.plaintext = utf8
            } else {
                self.plaintext = data.base64EncodedString()
            }
        } else {
            try value.encode(to: self)
        }
    }

    /// This ridiculously is a workaround for the inability of encoders to throw errors in various places. It's still better than fatalError()ing.
    struct FailureEncoder<K: CodingKey>: Encoder, KeyedEncodingContainerProtocol, UnkeyedEncodingContainer, SingleValueEncodingContainer {
        let codingPath: [any CodingKey] = []
        let userInfo: [CodingUserInfoKey: Any] = [:]
        let count = 0

        var error: EncodingError {
            .invalidValue((), .init(codingPath: [], debugDescription: "Plaintext encoding does not support nesting."))
        }

        init() {}
        init() where K == BasicCodingKey {}

        func encodeNil() throws {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering encodeNil()\n".utf8))
            throw self.error
        }
        func encodeNil(forKey: K) throws {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering encodeNil(forKey=\(forKey))\n".utf8))
			FileHandle.standardError.write(Data("[WARN] <<< Exiting encodeNil(forKey=\(forKey))\n".utf8))
            throw self.error
        }

        func encode(_: some Encodable) throws {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering encode()\n".utf8))
            throw self.error
        }
        func encode(_: some Encodable, forKey: K) throws {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(forKey=\(forKey))\n".utf8))
            throw self.error
        }

        func nestedContainer<N: CodingKey>(keyedBy: N.Type) -> KeyedEncodingContainer<N> {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering nestedContainer(keyedBy=\(keyedBy))\n".utf8))
            .init(FailureEncoder<N>())
        }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting nestedContainer(keyedBy=\(keyedBy))\n".utf8))
        func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey: K) -> KeyedEncodingContainer<N> {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering nestedContainer(keyedBy=\(keyedBy),forKey=\(forKey))\n".utf8))
            .init(FailureEncoder<N>())
        }

        func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering nestedUnkeyedContainer()\n".utf8))
            self
			FileHandle.standardError.write(Data("[WARN] <<< Exiting nestedUnkeyedContainer()\n".utf8))
        }
        func nestedUnkeyedContainer(forKey: K) -> any UnkeyedEncodingContainer {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering nestedUnkeyedContainer(forKey=\(forKey))\n".utf8))
            self
			FileHandle.standardError.write(Data("[WARN] <<< Exiting nestedUnkeyedContainer(forKey=\(forKey))\n".utf8))
        }

        func superEncoder() -> any Encoder {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering superEncoder()\n".utf8))
            self
			FileHandle.standardError.write(Data("[WARN] <<< Exiting superEncoder()\n".utf8))
        }
        func superEncoder(forKey: K) -> any Encoder {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering superEncoder(forKey=\(forKey))\n".utf8))
            self
			FileHandle.standardError.write(Data("[WARN] <<< Exiting superEncoder(forKey=\(forKey))\n".utf8))
        }

        func container<Key: CodingKey>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering container(keyedBy=\(keyedBy))\n".utf8))
            .init(FailureEncoder<Key>())
			FileHandle.standardError.write(Data("[WARN] <<< Exiting container(keyedBy=\(keyedBy))\n".utf8))
        }
        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering unkeyedContainer()\n".utf8))
            self
        }
        func singleValueContainer() -> any SingleValueEncodingContainer {
            FileHandle.standardError.write(Data("[ERROR] >>> Entering singleValueContainer()\n".utf8))
            self
        }
    }
}
