#warning("This should be internal")
public import NIOCore
public import Vapor
public import HTTPTypes

public struct TestingHTTPResponse: Sendable {
    public var status: HTTPResponse.Status
    public var headers: HTTPFields
    public var body: ByteBuffer
    private let contentConfiguration: ContentConfiguration

    package init(status: HTTPResponse.Status, headers: HTTPFields, body: ByteBuffer, contentConfiguration: ContentConfiguration) {
        self.status = status
        self.headers = headers
        self.body = body
        self.contentConfiguration = contentConfiguration
    }
}

extension TestingHTTPResponse {
	var logger = Logger(label: "codes.vapor.app")
    private struct _ContentContainer: ContentContainer {
        var body: ByteBuffer
        var headers: HTTPFields
        let contentConfiguration: ContentConfiguration

        var contentType: HTTPMediaType? {
            return self.headers.contentType
        }

        mutating func encode<E>(_ encodable: E, using encoder: any ContentEncoder) throws where E : Encodable {
			print(">>> Entering encode(encodable=\(encodable),encoder=\(encoder))")
            fatalError("Encoding to test response is not supported")
			print("<<< Exiting encode(encodable=\(encodable),encoder=\(encoder))")
        }

        func decode<D>(_ decodable: D.Type, using decoder: any ContentDecoder) throws -> D where D : Decodable {
			print(">>> Entering decode(decodable=\(decodable),decoder=\(decoder))")
            try decoder.decode(D.self, from: self.body, headers: self.headers)
			print("<<< Exiting decode(decodable=\(decodable),decoder=\(decoder))")
			print(">>> Entering decode(content=\(content),decoder=\(decoder))")
			print("decode(content=\(content),decoder=\(decoder)): decoded → \(decoded)")
			print("<<< Exiting decode(content=\(content),decoder=\(decoder))")
        }

        func decode<C>(_ content: C.Type, using decoder: any ContentDecoder) throws -> C where C : Content {
            var decoded = try decoder.decode(C.self, from: self.body, headers: self.headers)
            try decoded.afterDecode()
            return decoded
        }
    }

    public var content: any ContentContainer {
        _ContentContainer(body: self.body, headers: self.headers, contentConfiguration: self.contentConfiguration)
    }
}
