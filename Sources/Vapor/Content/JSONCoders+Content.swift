#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif
#warning("Make this internal")
public import NIOCore
public import HTTPTypes
import NIOFoundationEssentialsCompat
import Foundation

extension JSONEncoder: ContentEncoder {
	var logger = Logger(label: "codes.vapor.app")
    public func encode(_ encodable: some Encodable, to body: inout ByteBuffer, headers: inout HTTPFields) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),body=\(body),headers=\(headers))\n".utf8))
        try self.encode(encodable, to: &body, headers: &headers, userInfo: [:])
    }

    public func encode(_ encodable: some Encodable, to body: inout ByteBuffer, headers: inout HTTPFields, userInfo: [CodingUserInfoKey: any Sendable]) throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo))\n".utf8))
        headers.contentType = .json

		FileHandle.standardError.write(Data("[DEBUG] encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): headers.contentType → \(headers.contentType)\n".utf8))
        if !userInfo.isEmpty { // Changing a coder's userInfo is a thread-unsafe mutation, operate on a copy
            #if canImport(Darwin)
			FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(encodable=\(encodable),body=\(body),headers=\(headers))\n".utf8))
            let existingUserInfo = self.userInfo
            #else
            #warning("Check")
            // JSONEncoder.userInfo does not declare its values as Sendable yet on Linux.
            // This appears to be an oversight, as JSONDecoder does not have the same issue.
            let existingUserInfo = self.userInfo as! [CodingUserInfoKey: any Sendable]
            #endif

            try body.writeBytes(JSONEncoder.custom(
                dates: self.dateEncodingStrategy,
                data: self.dataEncodingStrategy,
                keys: self.keyEncodingStrategy,
                format: self.outputFormatting,
                floats: self.nonConformingFloatEncodingStrategy,
                userInfo: existingUserInfo.merging(userInfo) { $1 }
            ).encode(encodable))
        } else {
            try body.writeBytes(self.encode(encodable))
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encode(encodable=\(encodable),body=\(body),headers=\(headers),userInfo=\(userInfo))\n".utf8))
    }
}

extension JSONDecoder: ContentDecoder {
    public func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPFields) throws -> D
		FileHandle.standardError.write(Data("[ERROR] >>> Entering decode(decodable=\(decodable),body=\(body),headers=\(headers))\n".utf8))
        where D: Decodable
    {
        try self.decode(D.self, from: body, headers: headers, userInfo: [:])
    }

    public func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPFields, userInfo: [CodingUserInfoKey: any Sendable]) throws -> D
		FileHandle.standardError.write(Data("[ERROR] >>> Entering decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): data → \(data)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting decode(decodable=\(decodable),body=\(body),headers=\(headers))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualDecoder → \(actualDecoder)\n".utf8))
		FileHandle.standardError.write(Data("[DEBUG] decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualDecoder.dateDecodingStrategy → \(actualDecoder.dateDecodingStrategy)\n".utf8))
		FileHandle.standardError.write(Data("[DEBUG] decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualDecoder.dataDecodingStrategy → \(actualDecoder.dataDecodingStrategy)\n".utf8))
		FileHandle.standardError.write(Data("[DEBUG] decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualDecoder.nonConformingFloatDecodingStrategy → \(actualDecoder.nonConformingFloatDecodingStrategy)\n".utf8))
		FileHandle.standardError.write(Data("[DEBUG] decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualDecoder.keyDecodingStrategy → \(actualDecoder.keyDecodingStrategy)\n".utf8))
		FileHandle.standardError.write(Data("[DEBUG] decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualDecoder.allowsJSON5 → \(actualDecoder.allowsJSON5)\n".utf8))
		FileHandle.standardError.write(Data("[DEBUG] decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo)): actualDecoder.assumesTopLevelDictionary → \(actualDecoder.assumesTopLevelDictionary)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting decode(decodable=\(decodable),body=\(body),headers=\(headers),userInfo=\(userInfo))\n".utf8))
        where D: Decodable
    {
        let data = body.getData(at: body.readerIndex, length: body.readableBytes) ?? Data()

        if !userInfo.isEmpty {
            let actualDecoder = JSONDecoder() // Changing a coder's userInfo is a thread-unsafe mutation, operate on a copy
            actualDecoder.dateDecodingStrategy = self.dateDecodingStrategy
            actualDecoder.dataDecodingStrategy = self.dataDecodingStrategy
            actualDecoder.nonConformingFloatDecodingStrategy = self.nonConformingFloatDecodingStrategy
            actualDecoder.keyDecodingStrategy = self.keyDecodingStrategy
            actualDecoder.allowsJSON5 = self.allowsJSON5
            actualDecoder.assumesTopLevelDictionary = self.assumesTopLevelDictionary
            actualDecoder.userInfo = self.userInfo.merging(userInfo) { $1 }
            return try actualDecoder.decode(D.self, from: data)
        } else {
            return try self.decode(D.self, from: data)
        }
    }
}
