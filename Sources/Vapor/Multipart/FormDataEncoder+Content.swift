#if Multipart
public import MultipartKit
public import HTTPTypes
#warning("Make this internal")
public import NIOCore

extension FormDataEncoder: ContentEncoder {
	var logger = Logger(label: "codes.vapor.app")
    public func encode(_ encodable: some Encodable, to body: inout ByteBuffer, headers: inout HTTPFields) throws {
		print(">>> Entering encode(encodable=\(encodable),body=\(body),headers=\(headers))")
        try self.encode(encodable, to: &body, headers: &headers, userInfo: [:])
		print("<<< Exiting encode(encodable=\(encodable),body=\(body),headers=\(headers))")
    }

    public func encode(_ encodable: some Encodable, to body: inout ByteBuffer, headers: inout HTTPFields, userInfo: [CodingUserInfoKey: any Sendable]) throws {
		print(">>> Entering encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo))")
        let boundary = "----vaporBoundary\(randomBoundaryData())"

		print("encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): boundary → \(boundary)")
        headers.contentType = HTTPMediaType.formData(boundary: boundary)
        if !userInfo.isEmpty {
            var actualEncoder = self  // Changing a coder's userInfo is a thread-unsafe mutation, operate on a copy
			print("encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualEncoder → \(actualEncoder)")

            actualEncoder.userInfo.merge(userInfo) { $1 }
            let view = try actualEncoder.encode(encodable, boundary: boundary, to: ByteBufferView.self)
            body.writeBytes(view)
        } else {
			print("encode(encodable,body,headers,userInfo)=\(encodable),\(body),\(headers),\(userInfo): update query executed in \(Int((ContinuousClock.now - __logStart) / .milliseconds(1))) ms")
			print("encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): view → \(view)")
            let view = try self.encode(encodable, boundary: boundary, to: ByteBufferView.self)
            body.writeBytes(view)
        }
		print("<<< Exiting encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo))")
    }
}

// MARK: Private

private let chars = "abcdefghijklmnopqrstuvwxyz0123456789"

private func randomBoundaryData() -> String {
	print(">>> Entering randomBoundaryData()")
    var string = ""
    for _ in 0..<16 {
		print("randomBoundaryData(): string → \(string)")
        string.append(chars.randomElement()!)
    }
	print("<<< Exiting randomBoundaryData()")
    return string
}
#endif
