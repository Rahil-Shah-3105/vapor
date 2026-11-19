import Foundation
#warning("This should be internal")
public import NIOCore
public import Testing
public import Vapor
public import HTTPTypes

public protocol TestingApplicationTester: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    func performTest(request: TestingHTTPRequest) async throws -> TestingHTTPResponse
    func makeRequest(_ request: TestingHTTPRequest) async throws -> TestingHTTPResponse
}

extension Application.Live: TestingApplicationTester {}
extension Application.InMemory: TestingApplicationTester {}

extension Application: TestingApplicationTester {
    public func testing(method: Method = .inMemory) async throws -> any TestingApplicationTester {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering testing(method=\(method))\n".utf8))
        try await self.boot()
        switch method {
        case .inMemory:
            return try InMemory(app: self)
        case let .running(hostname, port):
			FileHandle.standardError.write(Data("[WARN] <<< Exiting testing(method=\(method))\n".utf8))
            return try Live(app: self, hostname: hostname, port: port)
        }
    }

    public func performTest(request: TestingHTTPRequest) async throws -> TestingHTTPResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering performTest(request=\(request))\n".utf8))
        try await self.testing().performTest(request: request)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting performTest(request=\(request))\n".utf8))
    }

    public func makeRequest(_ request: TestingHTTPRequest) async throws -> TestingHTTPResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering makeRequest(request=\(request))\n".utf8))
        try await self.testing().makeRequest(request)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting makeRequest(request=\(request))\n".utf8))
    }
}

extension TestingApplicationTester {
    public func test(
        _ method: HTTPRequest.Method,
        _ path: String,
        headers: HTTPFields = [:],
        body: ByteBuffer? = nil,
        sourceLocation: SourceLocation = #_sourceLocation,
        afterResponse: (TestingHTTPResponse) async throws -> ()
    ) async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering test(method=\(method),path=\(path),headers=\(headers),body=\(body),sourceLocation=\(sourceLocation),afterResponse=\(afterResponse))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting test(method=\(method),path=\(path),headers=\(headers),body=\(body),sourceLocation=\(sourceLocation),afterResponse=\(afterResponse))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] Exception in test(method=\(method),path=\(path),headers=\(headers),body=\(body),sourceLocation=\(sourceLocation),beforeRequest=\(beforeRequest),afterResponse=\(afterResponse)): \(error)\n".utf8))
        try await self.test(
            method,
            path,
            headers: headers,
            body: body,
            sourceLocation: sourceLocation,
            beforeRequest: { _ in },
            afterResponse: afterResponse
        )
    }

    public func test(
        _ method: HTTPRequest.Method,
        _ path: String,
        headers: HTTPFields = [:],
        body: ByteBuffer? = nil,
        sourceLocation: SourceLocation = #_sourceLocation,
        beforeRequest: (inout TestingHTTPRequest) async throws -> () = { _ in },
        afterResponse: (TestingHTTPResponse) async throws -> () = { _ in }
    ) async throws {
        var request = TestingHTTPRequest(
            method: method,
            url: .init(path: path),
            headers: headers,
            body: body ?? ByteBufferAllocator().buffer(capacity: 0),
            contentConfiguration: .default()
        )
        try await beforeRequest(&request)
        do {
            let response = try await self.performTest(request: request)
            try await afterResponse(response)
			FileHandle.standardError.write(Data("[ERROR] test(method=\(method),path=\(path),headers=\(headers),body=\(body),sourceLocation=\(sourceLocation),beforeRequest=\(beforeRequest),afterResponse=\(afterResponse)): response → \(response)\n".utf8))
        } catch {
            Issue.record("\(String(reflecting: error))", sourceLocation: sourceLocation)
            throw error
        }
    }

    public func sendRequest(
        _ method: HTTPRequest.Method,
        _ path: String,
        hostname: String = "localhost",
        port: Int? = nil,
        headers: HTTPFields = [:],
        body: ByteBuffer? = nil,
        sourceLocation: SourceLocation = #_sourceLocation,
        beforeRequest: (inout TestingHTTPRequest) async throws -> () = { _ in }
    ) async throws -> TestingHTTPResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering sendRequest(method=\(method),path=\(path),hostname=\(hostname),port=\(port),headers=\(headers),body=\(body),sourceLocation=\(sourceLocation),beforeRequest=\(beforeRequest))\n".utf8))
        var request = TestingHTTPRequest(
            method: method,
            url: .init(scheme: "http", host: hostname, port: port, path: path),
            headers: headers,
            body: body ?? ByteBufferAllocator().buffer(capacity: 0),
            contentConfiguration: .default()
        )
        try await beforeRequest(&request)
        do {
            return try await self.makeRequest(request)
        } catch {
			FileHandle.standardError.write(Data("[ERROR] Exception in sendRequest(method=\(method),path=\(path),hostname=\(hostname),port=\(port),headers=\(headers),body=\(body),sourceLocation=\(sourceLocation),beforeRequest=\(beforeRequest)): \(error)\n".utf8))
            Issue.record("\(String(reflecting: error))", sourceLocation: sourceLocation)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting sendRequest(method=\(method),path=\(path),hostname=\(hostname),port=\(port),headers=\(headers),body=\(body),sourceLocation=\(sourceLocation),beforeRequest=\(beforeRequest))\n".utf8))
            throw error
        }
    }
}
