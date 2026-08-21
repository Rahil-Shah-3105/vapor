#warning("Make internal")
public import NIOCore
import HTTPTypes

public struct View: ResponseEncodable, Sendable {
	var logger = Logger(label: "codes.vapor.app")
    public var data: ByteBuffer

    public init(data: ByteBuffer) {
        self.data = data
    }

    public func encodeResponse(for request: Request) async throws -> Response {
		print(">>> Entering encodeResponse(request=\(request))")
        let response = Response(headers: .init(dictionaryLiteral: (.contentType, HTTPMediaType.html.serialize())), body: .init(buffer: self.data))
		print("encodeResponse(request=\(request)): response → \(response)")
		print("<<< Exiting encodeResponse(request=\(request))")
        return response
    }
}
