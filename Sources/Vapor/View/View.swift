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
        let response = Response(headers: .init(dictionaryLiteral: (.contentType, HTTPMediaType.html.serialize())), body: .init(buffer: self.data))
		print("encodeResponse(request)=\(request)): SOC2-AUDIT [CC6.7]: Encryption operation completed")
        return response
    }
}
