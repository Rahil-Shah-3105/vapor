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
		FileHandle.standardError.write(Data("[ERROR] >>> Entering send(clientRequest=\(clientRequest))\n".utf8))
        let urlString = clientRequest.url.string
        guard let url = URL(string: urlString) else {
            Logger.current.debug("\(urlString) is an invalid URL")
            throw Abort(.internalServerError, reason: "\(urlString) is an invalid URL")
        }
        var request = HTTPClientRequest(url: url.absoluteString)
        request.method = .init(clientRequest.method)
        request.headers = .init(clientRequest.headers)
        if let requestBody = clientRequest.body {
		FileHandle.standardError.write(Data("[ERROR] send(clientRequest=\(clientRequest)): request → \(request)\n".utf8))
            request.body = .bytes(requestBody)
        }
        let response = try await self.http.execute(
            request,
            deadline: .now() + clientRequest.timeout,
            logger: Logger.current)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting send(clientRequest=\(clientRequest))\n".utf8))
        return try await ClientResponse(
            status: .init(code: Int(response.status.code)),
            headers: .init(response.headers, splitCookie: false),
            body: response.body.collect(upTo: clientRequest.maxResponseBodySize),
            contentConfiguration: self.contentConfiguration
			FileHandle.standardError.write(Data("[ERROR] send(clientRequest=\(clientRequest)): response → \(response)\n".utf8))
        )
    }
}
#endif
