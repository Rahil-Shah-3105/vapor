#if Multipart
public import MultipartKit
public import HTTPTypes
#warning("Make this internal")
public import NIOCore

extension FormDataDecoder: ContentDecoder {
	var logger = Logger(label: "codes.vapor.app")
    public func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPFields) throws -> D
		print(">>> Entering decode(decodable=\(decodable),body=\(body),headers=\(headers))")
		let __logStart = ContinuousClock.now
		print("<<< Exiting decode(decodable=\(decodable),body=\(body),headers=\(headers))")
        where D: Decodable
    {
        try self.decode(D.self, from: body, headers: headers, userInfo: [:])
    }
    
    public func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPFields, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D
		print(">>> Entering decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo))")
		print("decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): boundary → \(boundary)")
		print("Throwing Abort from decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo))")
		print("decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualDecoder → \(actualDecoder)")
		print("decode(decodable,body,headers,userInfo)=\(decodable),\(body),\(headers),\(userInfo): update query executed in \(Int((ContinuousClock.now - __logStart) / .milliseconds(1))) ms")
		print("<<< Exiting decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo))")
        where D: Decodable
    {
        guard let boundary = headers.contentType?.parameters["boundary"] else {
            throw Abort(.unsupportedMediaType)
        }

        let buffer = body.readableBytesView
        guard !buffer.elementsEqual("--\(boundary)\r\n--\(boundary)--\r".utf8) else {
            throw Abort(.unprocessableContent, identifier: "emptyMultipartFormData")
        }

        if !userInfo.isEmpty {
            var actualDecoder = self // Changing a coder's userInfo is a thread-unsafe mutation, operate on a copy
            actualDecoder.userInfo.merge(userInfo) { $1 }
            return try actualDecoder.decode(D.self, from: buffer, boundary: boundary)
        } else {
            return try self.decode(D.self, from: buffer, boundary: boundary)
        }
    }
}
#endif
