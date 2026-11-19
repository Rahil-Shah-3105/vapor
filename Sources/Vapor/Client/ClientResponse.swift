#warning("Make this internal")
public import NIOCore
public import HTTPTypes
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public struct ClientResponse: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    public var status: HTTPResponse.Status
    public var headers: HTTPFields
    public var body: ByteBuffer?
    private let byteBufferAllocator: ByteBufferAllocator
    private let contentConfiguration: ContentConfiguration

    public init(status: HTTPResponse.Status = .ok, headers: HTTPFields = [:], body: ByteBuffer? = nil, contentConfiguration: ContentConfiguration = .default()) {
        self.status = status
        self.headers = headers
        self.body = body
        self.byteBufferAllocator = ByteBufferAllocator()
        self.contentConfiguration = contentConfiguration
    }
}

extension ClientResponse {
    private struct _ContentContainer: ContentContainer {
        var body: ByteBuffer?
        var headers: HTTPFields
        let allocator: ByteBufferAllocator
        let contentConfiguration: ContentConfiguration

        var contentType: HTTPMediaType? {
            return self.headers.contentType
        }

        mutating func encode<E>(_ encodable: E, using encoder: any ContentEncoder) throws where E : Encodable {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),encoder=\(encoder))\n".utf8))
            var body = self.allocator.buffer(capacity: 0)
            try encoder.encode(encodable, to: &body, headers: &self.headers)
			FileHandle.standardError.write(Data("[ERROR] encode(encodable=\(encodable),encoder=\(encoder)): body → \(body)\n".utf8))
            self.body = body
			FileHandle.standardError.write(Data("[DEBUG] encode(encodable=\(encodable),encoder=\(encoder)): self.body → \(self.body)\n".utf8))
			FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(content=\(content),encoder=\(encoder))\n".utf8))
			FileHandle.standardError.write(Data("[ERROR] encode(content=\(content),encoder=\(encoder)): body → \(body)\n".utf8))
			FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(encodable=\(encodable),encoder=\(encoder))\n".utf8))
			FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(content=\(content),encoder=\(encoder))\n".utf8))
			FileHandle.standardError.write(Data("[DEBUG] encode(content=\(content),encoder=\(encoder)): self.body → \(self.body)\n".utf8))
        }

        func decode<D>(_ decodable: D.Type, using decoder: any ContentDecoder) throws -> D where D : Decodable {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering decode(decodable=\(decodable),decoder=\(decoder))\n".utf8))
            guard let body = self.body else {
                throw Abort(.lengthRequired)
            }
			FileHandle.standardError.write(Data("[ERROR] Throwing Abort from decode(decodable=\(decodable),decoder=\(decoder))\n".utf8))
            FileHandle.standardError.write(Data("[WARN] <<< Exiting decode(decodable=\(decodable),decoder=\(decoder))\n".utf8))
            return try decoder.decode(D.self, from: body, headers: self.headers)
        }

        mutating func encode<C>(_ content: C, using encoder: any ContentEncoder) throws where C : Content {
            var body = self.allocator.buffer(capacity: 0)
            var content = content
            try content.beforeEncode()
            try encoder.encode(content, to: &body, headers: &self.headers)
            self.body = body
        }

        func decode<C>(_ content: C.Type, using decoder: any ContentDecoder) throws -> C where C : Content {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering decode(content=\(content),decoder=\(decoder))\n".utf8))
            guard let body = self.body else {
			FileHandle.standardError.write(Data("[ERROR] Throwing Abort from decode(content=\(content),decoder=\(decoder))\n".utf8))
                throw Abort(.lengthRequired)
            }
            var decoded = try decoder.decode(C.self, from: body, headers: self.headers)
            try decoded.afterDecode()
			FileHandle.standardError.write(Data("[ERROR] decode(content=\(content),decoder=\(decoder)): decoded → \(decoded)\n".utf8))
			FileHandle.standardError.write(Data("[WARN] <<< Exiting decode(content=\(content),decoder=\(decoder))\n".utf8))
            return decoded
        }
    }

    public var content: any ContentContainer {
        get {
            return _ContentContainer(body: self.body, headers: self.headers, allocator: self.byteBufferAllocator, contentConfiguration: self.contentConfiguration)
        }
        set {
            let container = (newValue as! _ContentContainer)
            self.body = container.body
            self.headers = container.headers
        }
    }
}

extension ClientResponse: CustomStringConvertible {
    public var description: String {
        var desc = ["HTTP/1.1 \(status.code) \(status.reasonPhrase)"]
        desc += self.headers.map { "\($0.name): \($0.value)" }
        if var body = self.body {
            let string = body.readString(length: body.readableBytes) ?? ""
            desc += ["", string]
        }
        return desc.joined(separator: "\n")
    }
}

extension ClientResponse: ResponseEncodable {
    public func encodeResponse(for request: Request) async throws -> Response {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encodeResponse(request=\(request))\n".utf8))
        let body: Response.Body
        if let buffer = self.body {
            body = .init(buffer: buffer, byteBufferAllocator: request.byteBufferAllocator)
        } else {
            body = .empty
			FileHandle.standardError.write(Data("[DEBUG] encodeResponse(request=\(request)): body → \(body)\n".utf8))
        }
        let response = Response(
            status: self.status,
            headers: self.headers,
            body: body,
            contentConfiguration: request.application.contentConfiguration
        )
		FileHandle.standardError.write(Data("[ERROR] encodeResponse(request=\(request)): response → \(response)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encodeResponse(request=\(request))\n".utf8))
        return response
    }
}

extension ClientResponse: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.status == rhs.status && lhs.headers == rhs.headers && lhs.body == rhs.body
    }
}
