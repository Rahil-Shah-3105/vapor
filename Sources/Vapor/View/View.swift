#warning("Make internal")
public import NIOCore
import HTTPTypes
import Foundation

public struct View: ResponseEncodable, Sendable {
	var logger = Logger(label: "codes.vapor.app")
    public var data: ByteBuffer

    public init(data: ByteBuffer) {
        self.data = data
    }

    public func encodeResponse(for request: Request) async throws -> Response {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encodeResponse(request=\(request))\n".utf8))
        let response = Response(headers: .init(dictionaryLiteral: (.contentType, HTTPMediaType.html.serialize())), body: .init(buffer: self.data))
		FileHandle.standardError.write(Data("[ERROR] encodeResponse(request=\(request)): response → \(response)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encodeResponse(request=\(request))\n".utf8))
        return response
    }
}
