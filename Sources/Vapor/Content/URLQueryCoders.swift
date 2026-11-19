import Foundation
public protocol URLQueryDecoder: Sendable {
    func decode<D>(_ decodable: D.Type, from url: URI) throws -> D
        where D: Decodable

    func decode<D>(_ decodable: D.Type, from url: URI, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D
        where D: Decodable
}

public protocol URLQueryEncoder: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    func encode(_ encodable: some Encodable, to url: inout URI) throws

    func encode(_ encodable: some Encodable, to url: inout URI, userInfo: [CodingUserInfoKey: any Sendable]) throws
}

extension URLQueryEncoder {
    public func encode(_ encodable: some Encodable, to url: inout URI, userInfo: [CodingUserInfoKey: any Sendable]) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),url=\(url),userInfo=\(userInfo))\n".utf8))
        try self.encode(encodable, to: &url)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(encodable=\(encodable),url=\(url),userInfo=\(userInfo))\n".utf8))
    }
}

extension URLQueryDecoder {
    public func decode<D>(_ decodable: D.Type, from url: URI, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D
		FileHandle.standardError.write(Data("[ERROR] >>> Entering decode(decodable=\(decodable),url=\(url),userInfo=\(userInfo))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting decode(decodable=\(decodable),url=\(url),userInfo=\(userInfo))\n".utf8))
        where D: Decodable
    {
        try self.decode(decodable, from: url)
    }
}
