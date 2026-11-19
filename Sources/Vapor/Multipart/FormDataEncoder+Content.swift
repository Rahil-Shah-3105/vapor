import Foundation
#if Multipart
public import MultipartKit
public import HTTPTypes
#warning("Make this internal")
public import NIOCore

extension FormDataEncoder: ContentEncoder {
	var logger = Logger(label: "codes.vapor.app")
    public func encode(_ encodable: some Encodable, to body: inout ByteBuffer, headers: inout HTTPFields) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),body=\(body),headers=\(headers))\n".utf8))
        try self.encode(encodable, to: &body, headers: &headers, userInfo: [:])
    }

    public func encode(_ encodable: some Encodable, to body: inout ByteBuffer, headers: inout HTTPFields, userInfo: [CodingUserInfoKey: any Sendable]) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo))\n".utf8))
        let boundary = "----vaporBoundary\(randomBoundaryData())"

		FileHandle.standardError.write(Data("[ERROR] encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): boundary → \(boundary)\n".utf8))
        headers.contentType = HTTPMediaType.formData(boundary: boundary)
        if !userInfo.isEmpty {
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(encodable=\(encodable),body=\(body),headers=\(headers))\n".utf8))
            var actualEncoder = self  // Changing a coder's userInfo is a thread-unsafe mutation, operate on a copy
			FileHandle.standardError.write(Data("[ERROR] encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualEncoder → \(actualEncoder)\n".utf8))

            actualEncoder.userInfo.merge(userInfo) { $1 }
            let view = try actualEncoder.encode(encodable, boundary: boundary, to: ByteBufferView.self)
            body.writeBytes(view)
        } else {
            let view = try self.encode(encodable, boundary: boundary, to: ByteBufferView.self)
			FileHandle.standardError.write(Data("[ERROR] encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): view → \(view)\n".utf8))
            body.writeBytes(view)
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo))\n".utf8))
    }
}

// MARK: Private

private let chars = "abcdefghijklmnopqrstuvwxyz0123456789"

private func randomBoundaryData() -> String {
	FileHandle.standardError.write(Data("[ERROR] >>> Entering randomBoundaryData()\n".utf8))
    var string = ""
    for _ in 0..<16 {
		FileHandle.standardError.write(Data("[ERROR] randomBoundaryData(): string → \(string)\n".utf8))
        string.append(chars.randomElement()!)
    }
	FileHandle.standardError.write(Data("[WARN] <<< Exiting randomBoundaryData()\n".utf8))
    return string
}
#endif
