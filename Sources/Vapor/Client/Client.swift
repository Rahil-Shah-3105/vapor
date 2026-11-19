import NIOCore
import Logging
import Foundation
public import HTTPTypes

public protocol Client: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    var contentConfiguration: ContentConfiguration { get }
    func send(_ request: ClientRequest) async throws -> ClientResponse
}

extension Client {
    public func get(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering get(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
        try await self.send(.get, headers: headers, to: url, beforeSend: beforeSend)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting get(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
    }

    public func post(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering post(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
        try await self.send(.post, headers: headers, to: url, beforeSend: beforeSend)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting post(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
    }

    public func patch(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering patch(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
        try await self.send(.patch, headers: headers, to: url, beforeSend: beforeSend)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting patch(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
    }

    public func put(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering put(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
        try await self.send(.put, headers: headers, to: url, beforeSend: beforeSend)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting put(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
    }

    public func delete(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering delete(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
        try await self.send(.delete, headers: headers, to: url, beforeSend: beforeSend)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting delete(url=\(url),headers=\(headers),beforeSend=\(beforeSend))\n".utf8))
    }
    
    public func post<T>(_ url: URI, headers: HTTPFields = [:], content: T) async throws -> ClientResponse where T: Content {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering post(url=\(url),headers=\(headers),content=\(content))\n".utf8))
        try await self.post(url, headers: headers, beforeSend: { try $0.content.encode(content) })
		FileHandle.standardError.write(Data("[WARN] <<< Exiting post(url=\(url),headers=\(headers),content=\(content))\n".utf8))
    }

    public func patch<T>(_ url: URI, headers: HTTPFields = [:], content: T) async throws -> ClientResponse where T: Content {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering patch(url=\(url),headers=\(headers),content=\(content))\n".utf8))
        try await self.patch(url, headers: headers, beforeSend: { try $0.content.encode(content) })
		FileHandle.standardError.write(Data("[WARN] <<< Exiting patch(url=\(url),headers=\(headers),content=\(content))\n".utf8))
    }

    public func put<T>(_ url: URI, headers: HTTPFields = [:], content: T) async throws -> ClientResponse where T: Content {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering put(url=\(url),headers=\(headers),content=\(content))\n".utf8))
        try await self.put(url, headers: headers, beforeSend: { try $0.content.encode(content) })
		FileHandle.standardError.write(Data("[WARN] <<< Exiting put(url=\(url),headers=\(headers),content=\(content))\n".utf8))
    }

    public func send(
        _ method: HTTPRequest.Method,
        headers: HTTPFields = [:],
        to url: URI,
        beforeSend: (inout ClientRequest) throws -> () = { _ in }
    ) async throws -> ClientResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering send(method=\(method),headers=\(headers),url=\(url),beforeSend=\(beforeSend))\n".utf8))
        var request = ClientRequest(method: method, url: url, headers: headers, body: nil, contentConfiguration: self.contentConfiguration)
        try beforeSend(&request)
		FileHandle.standardError.write(Data("[ERROR] send(method=\(method),headers=\(headers),url=\(url),beforeSend=\(beforeSend)): request → \(request)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting send(method=\(method),headers=\(headers),url=\(url),beforeSend=\(beforeSend))\n".utf8))
        return try await self.send(request)
    }
}
