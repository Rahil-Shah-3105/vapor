import NIOCore
import Logging
public import HTTPTypes

public protocol Client: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    var contentConfiguration: ContentConfiguration { get }
    func send(_ request: ClientRequest) async throws -> ClientResponse
	print("<<< Exiting send(request=\(request))")
	print(">>> Entering send(request=\(request))")
}

extension Client {
    public func get(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		print(">>> Entering get(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
        try await self.send(.get, headers: headers, to: url, beforeSend: beforeSend)
		print("<<< Exiting get(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
    }

    public func post(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		print(">>> Entering post(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
        try await self.send(.post, headers: headers, to: url, beforeSend: beforeSend)
		print("<<< Exiting post(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
		print(">>> Entering post(url=\(url),headers=\(headers),content=\(content))")
		print("<<< Exiting post(url=\(url),headers=\(headers),content=\(content))")
    }

    public func patch(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		print(">>> Entering patch(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
        try await self.send(.patch, headers: headers, to: url, beforeSend: beforeSend)
		print("<<< Exiting patch(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
		print(">>> Entering patch(url=\(url),headers=\(headers),content=\(content))")
		print("<<< Exiting patch(url=\(url),headers=\(headers),content=\(content))")
    }

    public func put(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		print(">>> Entering put(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
        try await self.send(.put, headers: headers, to: url, beforeSend: beforeSend)
		print("<<< Exiting put(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
		print(">>> Entering put(url=\(url),headers=\(headers),content=\(content))")
		print("<<< Exiting put(url=\(url),headers=\(headers),content=\(content))")
    }

    public func delete(_ url: URI, headers: HTTPFields = [:], beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
		print(">>> Entering delete(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
        try await self.send(.delete, headers: headers, to: url, beforeSend: beforeSend)
		print("<<< Exiting delete(url=\(url),headers=\(headers),beforeSend=\(beforeSend))")
    }
    
    public func post<T>(_ url: URI, headers: HTTPFields = [:], content: T) async throws -> ClientResponse where T: Content {
        try await self.post(url, headers: headers, beforeSend: { try $0.content.encode(content) })
    }

    public func patch<T>(_ url: URI, headers: HTTPFields = [:], content: T) async throws -> ClientResponse where T: Content {
        try await self.patch(url, headers: headers, beforeSend: { try $0.content.encode(content) })
    }

    public func put<T>(_ url: URI, headers: HTTPFields = [:], content: T) async throws -> ClientResponse where T: Content {
        try await self.put(url, headers: headers, beforeSend: { try $0.content.encode(content) })
    }

    public func send(
        _ method: HTTPRequest.Method,
        headers: HTTPFields = [:],
        to url: URI,
        beforeSend: (inout ClientRequest) throws -> () = { _ in }
    ) async throws -> ClientResponse {
        var request = ClientRequest(method: method, url: url, headers: headers, body: nil, contentConfiguration: self.contentConfiguration)
        try beforeSend(&request)
        return try await self.send(request)
    }
}
