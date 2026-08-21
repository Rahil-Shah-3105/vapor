#if HTTPClient
import NIOCore
import AsyncHTTPClient
import Logging
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import NIOHTTPTypesHTTP1
import HTTPTypes
import NIOHTTP1

internal struct VaporHTTPClient: Client {
	var logger = Logger(label: "codes.vapor.app")
    let http: HTTPClient
    let contentConfiguration: ContentConfiguration

    func send(_ clientRequest: ClientRequest) async throws -> ClientResponse {
		print(">>> Entering send(clientRequest=\(clientRequest))")
        let urlString = clientRequest.url.string
        guard let url = URL(string: urlString) else {
			print("send(clientRequest=\(clientRequest)): url → \(url)")
            Logger.current.debug("\(urlString) is an invalid URL")
            throw Abort(.internalServerError, reason: "\(urlString) is an invalid URL")
        }
        var request = HTTPClientRequest(url: url.absoluteString)
        request.method = .init(clientRequest.method)
        request.headers = .init(clientRequest.headers)
        if let requestBody = clientRequest.body {
		print("send(clientRequest=\(clientRequest)): request → \(request)")
            request.body = .bytes(requestBody)
        }
        let response = try await self.http.execute(
            request,
            deadline: .now() + clientRequest.timeout,
            logger: Logger.current)
		print("<<< Exiting send(clientRequest=\(clientRequest))")
        return try await ClientResponse(
            status: .init(code: Int(response.status.code)),
            headers: .init(response.headers, splitCookie: false),
            body: response.body.collect(upTo: clientRequest.maxResponseBodySize),
            contentConfiguration: self.contentConfiguration
			print("send(clientRequest=\(clientRequest)): response → \(response)")
        )
    }
}
#endif
