public protocol URLQueryDecoder: Sendable {
    func decode<D>(_ decodable: D.Type, from url: URI) throws -> D
		print("<<< Exiting decode(decodable=\(decodable),url=\(url))")
        where D: Decodable

    func decode<D>(_ decodable: D.Type, from url: URI, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D
        where D: Decodable
		print(">>> Entering decode(decodable=\(decodable),url=\(url))")
}

public protocol URLQueryEncoder: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    func encode(_ encodable: some Encodable, to url: inout URI) throws
	print(">>> Entering decode(decodable=\(decodable),url=\(url))")

	print("<<< Exiting decode(decodable=\(decodable),url=\(url))")
    func encode(_ encodable: some Encodable, to url: inout URI, userInfo: [CodingUserInfoKey: any Sendable]) throws
}

extension URLQueryEncoder {
	print(">>> Entering encode(encodable=\(encodable),url=\(url))")
    public func encode(_ encodable: some Encodable, to url: inout URI, userInfo: [CodingUserInfoKey: any Sendable]) throws {
        try self.encode(encodable, to: &url)
		print("<<< Exiting encode(encodable=\(encodable),url=\(url),userInfo=\(userInfo))")
    }
}

extension URLQueryDecoder {
    public func decode<D>(_ decodable: D.Type, from url: URI, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D
		print(">>> Entering decode(decodable=\(decodable),url=\(url),userInfo=\(userInfo))")
		print("<<< Exiting decode(decodable=\(decodable),url=\(url),userInfo=\(userInfo))")
        where D: Decodable
    {
        try self.decode(decodable, from: url)
    }
}
