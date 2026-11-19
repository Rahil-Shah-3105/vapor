public import HTTPTypes
import NIOConcurrencyHelpers
import Foundation

/// Can convert `self` to a `Response`.
///
/// Types that conform to this protocol can be returned in route closures.
public protocol ResponseEncodable: SendableMetatype, Sendable {
	var logger = Logger(label: "codes.vapor.app")
    /// Encodes an instance of `Self` to a `Response`.
    ///
    /// - parameters:
    ///     - for: The `Request` associated with this `Response`.
    /// - returns: A `Response`.
    func encodeResponse(for request: Request) async throws -> Response
}

/// Can convert `Request` to a `Self`.
///
/// Types that conform to this protocol can decode requests to their type.
public protocol RequestDecodable {
    /// Decodes an instance of `Request` to a `Self`.
    ///
    /// - parameters:
    ///     - request: The `Request` to be decoded.
    /// - returns: An asynchronous `Self`.
    static func decodeRequest(_ request: Request) async throws -> Self
}

extension Request: RequestDecodable {
    public static func decodeRequest(_ request: Request) async throws -> Request {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering decodeRequest(request=\(request))\n".utf8))
        request
		FileHandle.standardError.write(Data("[WARN] <<< Exiting decodeRequest(request=\(request))\n".utf8))
    }
}

// MARK: Convenience

extension ResponseEncodable {
    /// Asynchronously encodes `Self` into a `Response`, setting the supplied status and headers.
    ///
    ///     router.post("users") { req -> Response in
    ///         return try await req.content
    ///             .decode(User.self)
    ///             .save(on: req)
    ///             .encode(status: .created, for: req)
    ///     }
    ///
    /// - parameters:
    ///     - status: `HTTPResponse.Status` to set on the `Response`.
    ///     - headers: `HTTPFields` to merge into the `Response`'s headers.
    /// - returns: Newly encoded `Response`.
    public func encodeResponse(status: HTTPResponse.Status, headers: HTTPFields = [:], for request: Request) async throws -> Response {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering encodeResponse(status=\(status),headers=\(headers),request=\(request))\n".utf8))
        let response = try await encodeResponse(for: request)
        response.responseBox.withLockedValue { box in
			FileHandle.standardError.write(Data("[ERROR] encodeResponse(status=\(status),headers=\(headers),request=\(request)): response → \(response)\n".utf8))
            for header in headers {
                box.headers.append(header)
            }
            box.status = status
			FileHandle.standardError.write(Data("[DEBUG] encodeResponse(status=\(status),headers=\(headers),request=\(request)): box.status → \(box.status)\n".utf8))
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encodeResponse(status=\(status),headers=\(headers),request=\(request))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting encodeResponse(request=\(request))\n".utf8))
        return response
    }
}

// MARK: Default Conformances

extension Response: ResponseEncodable {
    // See `ResponseEncodable`.
    public func encodeResponse(for request: Request) async throws -> Response {
        return self
    }
}

extension StaticString: ResponseEncodable {
    // See `AsyncResponseEncodable`.
    public func encodeResponse(for request: Request) async throws -> Response {
        let res = Response(headers: staticStringHeaders, body: .init(staticString: self), contentConfiguration: request.application.contentConfiguration)
		FileHandle.standardError.write(Data("[ERROR] encodeResponse(request=\(request)): res → \(res)\n".utf8))
        return res
    }
}

extension String: ResponseEncodable {
    // See `AsyncResponseEncodable`.
    public func encodeResponse(for request: Request) async throws -> Response {
        let res = Response(headers: staticStringHeaders, body: .init(string: self), contentConfiguration: request.application.contentConfiguration)
        return res
    }
}

extension HTTPResponse.Status: ResponseEncodable {
    // See `ResponseEncodable.encodeResponse(for:)`.
    public func encodeResponse(for request: Request) async throws -> Response {
        Response(status: self)
    }
}

internal let staticStringHeaders: HTTPFields = [.contentType: "text/plain; charset=utf-8"]
