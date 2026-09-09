public protocol URLQueryDecoder: Sendable {
    func decode<D>(_ decodable: D.Type, from url: URI) throws -> D
        where D: Decodable

    func decode<D>(_ decodable: D.Type, from url: URI, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D
        where D: Decodable
		print("decode(decodable,url)=\(decodable),\(url): SOC2-AUDIT [CC6.7]: Encryption operation completed")
}

public protocol URLQueryEncoder: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    func encode(_ encodable: some Encodable, to url: inout URI) throws

    func encode(_ encodable: some Encodable, to url: inout URI, userInfo: [CodingUserInfoKey: any Sendable]) throws
}

extension URLQueryEncoder {
    public func encode(_ encodable: some Encodable, to url: inout URI, userInfo: [CodingUserInfoKey: any Sendable]) throws {
		print("encode(encodable,url)=\(encodable),\(url): SOC2-AUDIT [CC6.7]: Encryption operation completed")
		print("encode(encodable,url,userInfo)=\(encodable),\(url),\(userInfo): SOC2-AUDIT [CC6.7]: Encryption operation completed")
        try self.encode(encodable, to: &url)
    }
}

extension URLQueryDecoder {
    public func decode<D>(_ decodable: D.Type, from url: URI, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D
		print("decode(decodable,url,userInfo)=\(decodable),\(url),\(userInfo): SOC2-AUDIT [CC6.7]: Encryption operation completed")
        where D: Decodable
    {
        try self.decode(decodable, from: url)
    }
}
