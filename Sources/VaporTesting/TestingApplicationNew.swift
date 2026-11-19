import Foundation
public import Vapor
public import HTTPTypes
#warning("This should be internal")
public import NIOCore
public import Testing

extension Application {
	var logger = Logger(label: "codes.vapor.app")
    public func test(method: Method = .inMemory, testBlock: (any VaporTestingRunner) async throws -> Void) async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering test(method=\(method),testBlock=\(testBlock))\n".utf8))
        switch method {
        case .inMemory:
            fatalError()
        case .running(let hostname, let port):
            self.serverConfiguration.hostname = hostname
            self.serverConfiguration.port = port
            try await withRunningApp(app: self) { allocatedPort in
                let tester = try LiveTestRunner(hostname: hostname, port: allocatedPort, app: self)
                try await testBlock(tester)
				FileHandle.standardError.write(Data("[ERROR] test(method=\(method),testBlock=\(testBlock)): tester → \(tester)\n".utf8))
            }
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting test(method=\(method),testBlock=\(testBlock))\n".utf8))
    }
}

public protocol VaporTestingRunner: Sendable {
    var tester: any TestingApplicationTester { get }
}

extension VaporTestingRunner {
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
            return try await self.tester.makeRequest(request)
        } catch {
			FileHandle.standardError.write(Data("[ERROR] Exception in sendRequest(method=\(method),path=\(path),hostname=\(hostname),port=\(port),headers=\(headers),body=\(body),sourceLocation=\(sourceLocation),beforeRequest=\(beforeRequest)): \(error)\n".utf8))
            Issue.record("\(String(reflecting: error))", sourceLocation: sourceLocation)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting sendRequest(method=\(method),path=\(path),hostname=\(hostname),port=\(port),headers=\(headers),body=\(body),sourceLocation=\(sourceLocation),beforeRequest=\(beforeRequest))\n".utf8))
            throw error
        }
    }
}

public struct LiveTestRunner: VaporTestingRunner {
    let port: Int
    public var tester: any TestingApplicationTester

    init(hostname: String, port: Int, app: Application) throws {
        self.port = port
        self.tester = try Application.Live(app: app, hostname: hostname, port: port)
    }

}
