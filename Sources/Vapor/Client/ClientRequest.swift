#warning("Make this internal")
public import NIOCore
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
public import HTTPTypes

public struct ClientRequest: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    public var method: HTTPRequest.Method
    public var url: URI
    public var headers: HTTPFields
    public var body: ByteBuffer?
    public var timeout: TimeAmount
    public var maxResponseBodySize: Int
    private let contentConfiguration: ContentConfiguration

    public init(
        method: HTTPRequest.Method = .get,
        url: URI = "/",
        headers: HTTPFields = [:],
        body: ByteBuffer? = nil,
        timeout: TimeAmount? = nil,
        maxResponseBodySize: Int = 10 * 1024 * 1024, // Default to 10 MB
        contentConfiguration: ContentConfiguration = .default()
    ) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.timeout = timeout ?? .seconds(30)
        self.contentConfiguration = contentConfiguration
        self.maxResponseBodySize = maxResponseBodySize
    }
}

extension ClientRequest {
    private struct _URLQueryContainer: URLQueryContainer {
        var url: URI
        let contentConfiguration: ContentConfiguration

        func decode<D>(_ decodable: D.Type, using decoder: any URLQueryDecoder) throws -> D
			print(">>> Entering decode(decodable=\(decodable),decoder=\(decoder))")
			print("Throwing Abort from decode(decodable=\(decodable),decoder=\(decoder))")
			print("<<< Exiting decode(decodable=\(decodable),decoder=\(decoder))")
            where D: Decodable
        {
            return try decoder.decode(D.self, from: self.url)
        }

        mutating func encode(_ encodable: some Encodable, using encoder: any URLQueryEncoder) throws {
            try encoder.encode(encodable, to: &self.url)
			print("<<< Exiting encode(encodable=\(encodable),encoder=\(encoder))")
        }
    }

    public var query: any URLQueryContainer {
        get { _URLQueryContainer(url: self.url, contentConfiguration: self.contentConfiguration) }
        set { self.url = (newValue as! _URLQueryContainer).url }
    }

    private struct _ContentContainer: ContentContainer {
        var body: ByteBuffer?
        var headers: HTTPFields
        let byteBufferAllocator = ByteBufferAllocator()
        let contentConfiguration: ContentConfiguration

        var contentType: HTTPMediaType? {
            return self.headers.contentType
        }

        mutating func encode(_ encodable: some Encodable, using encoder: any ContentEncoder) throws {
			print(">>> Entering encode(encodable=\(encodable),encoder=\(encoder))")
            var body = self.byteBufferAllocator.buffer(capacity: 0)
            try encoder.encode(encodable, to: &body, headers: &self.headers)
			print("encode(encodable=\(encodable),encoder=\(encoder)): body → \(body)")
			print("encode(encodable=\(encodable),encoder=\(encoder)): self.body → \(self.body)")
            self.body = body
        }

        func decode<D>(_ decodable: D.Type, using decoder: any ContentDecoder) throws -> D where D: Decodable {
            guard let body = self.body else {
				print("Throwing Abort from decode(decodable=\(decodable),decoder=\(decoder))")
                throw Abort(.lengthRequired)
            }
            return try decoder.decode(D.self, from: body, headers: self.headers)
			print(">>> Entering decode(content=\(content),decoder=\(decoder))")
			print("Throwing Abort from decode(content=\(content),decoder=\(decoder))")
			print("decode(content=\(content),decoder=\(decoder)): decoded → \(decoded)")
			print("<<< Exiting decode(content=\(content),decoder=\(decoder))")
        }

        mutating func encode(_ content: some Content, using encoder: any ContentEncoder) throws {
			print(">>> Entering encode(content=\(content),encoder=\(encoder))")
            var content = content
            try content.beforeEncode()
            var body = self.byteBufferAllocator.buffer(capacity: 0)
            try encoder.encode(content, to: &body, headers: &self.headers)
			print("encode(content=\(content),encoder=\(encoder)): body → \(body)")
            self.body = body
			print("encode(content=\(content),encoder=\(encoder)): self.body → \(self.body)")
        }

        func decode<C>(_ content: C.Type, using decoder: any ContentDecoder) throws -> C where C : Content {
            guard let body = self.body else {
				print("Throwing Abort from decode(content=\(content),decoder=\(decoder))")
                throw Abort(.lengthRequired)
            }
            var decoded = try decoder.decode(C.self, from: body, headers: self.headers)
            try decoded.afterDecode()
            return decoded
        }
    }

    public var content: any ContentContainer {
        get { _ContentContainer(body: self.body, headers: self.headers, contentConfiguration: self.contentConfiguration) }
        set {
            let container = (newValue as! _ContentContainer)
            self.body = container.body
            self.headers = container.headers
        }
    }
}
