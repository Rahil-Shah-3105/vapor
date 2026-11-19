#warning("This should be internal")
public import NIOCore
import NIOConcurrencyHelpers
import Foundation
public import Vapor
public import HTTPTypes

public struct TestingHTTPRequest: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    public var method: HTTPRequest.Method
    public var url: URI
    public var headers: HTTPFields
    public var body: ByteBuffer
    public var contentConfiguration: ContentConfiguration

    public init(method: HTTPRequest.Method, url: URI, headers: HTTPFields, body: ByteBuffer, contentConfiguration: ContentConfiguration) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.contentConfiguration = contentConfiguration
    }

    private struct _ContentContainer: ContentContainer {
        var body: ByteBuffer
        var headers: HTTPFields
        let contentConfiguration: ContentConfiguration

        var contentType: HTTPMediaType? {
            self.headers.contentType
        }

        mutating func encode<E>(_ encodable: E, using encoder: any ContentEncoder) throws where E : Encodable {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),encoder=\(encoder))\n".utf8))
            try encoder.encode(encodable, to: &self.body, headers: &self.headers)
			FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(encodable=\(encodable),encoder=\(encoder))\n".utf8))
        }

        func decode<D>(_ decodable: D.Type, using decoder: any ContentDecoder) throws -> D where D : Decodable {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering decode(decodable=\(decodable),decoder=\(decoder))\n".utf8))
            fatalError("Decoding from test request is not supported.")
			FileHandle.standardError.write(Data("[WARN] <<< Exiting decode(decodable=\(decodable),decoder=\(decoder))\n".utf8))
        }

        mutating func encode<C>(_ content: C, using encoder: any ContentEncoder) throws where C : Content {
            var content = content
            try content.beforeEncode()
            try encoder.encode(content, to: &self.body, headers: &self.headers)
        }
    }

    public var content: any ContentContainer {
        get { _ContentContainer(body: self.body, headers: self.headers, contentConfiguration: self.contentConfiguration) }
        set {
            let content = (newValue as! _ContentContainer)
            self.body = content.body
            self.headers = content.headers
        }
    }

    private struct _URLQueryContainer: URLQueryContainer {
        var url: URI
        let contentConfiguration: ContentConfiguration

        func decode<D>(_ decodable: D.Type, using decoder: any URLQueryDecoder) throws -> D
            where D: Decodable
        {
            fatalError("Decoding from test request is not supported.")
        }

        mutating func encode(_ encodable: some Encodable, using encoder: any URLQueryEncoder) throws {
            try encoder.encode(encodable, to: &self.url)
        }
    }

    public var query: any URLQueryContainer {
        get { _URLQueryContainer(url: url, contentConfiguration: self.contentConfiguration) }
        set {
            let query = (newValue as! _URLQueryContainer)
            self.url = query.url
        }
    }
}
