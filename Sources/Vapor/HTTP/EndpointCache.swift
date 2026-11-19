#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import NIOConcurrencyHelpers
import NIOCore
import Logging
public import HTTPTypes

public enum EndpointCacheError: Swift.Error {
    case unexpectedResponseStatus(HTTPResponse.Status, uri: URI)
    case contentDecodeFailure(any Error)

    @available(*, deprecated, renamed: "unexpectedResponseStatus")
    public static func unexpctedResponseStatus(_ status: HTTPResponse.Status, uri: URI) -> Self {
        .unexpectedResponseStatus(status, uri: uri)
    }
}

/// Handles the complexities of HTTP caching.
public actor EndpointCache<T>: Sendable where T: Decodable & Sendable {
    private var cached: (cachedData: T?, cacheDate: Date?)
    private var request: Task<T, any Error>?
    private var headers: HTTPFields?
    private let uri: URI

    /// The designated initializer.
    /// - Parameters:
    ///   - uri: The `URI` of the resource to be downloaded.
    public init(uri: URI) {
        self.uri = uri
        self.request = nil
        self.headers = nil
        self.cached = (nil, nil)
    }

    /// Downloads the resource.
    /// - Parameters:
    ///   - request: The `Request` which is initiating the download.
    public func get(on request: Request) async throws -> T {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering get(request=\(request))\n".utf8))
        try await self.download(using: request.application.client)
    }

    /// Downloads the resource.
    /// - Parameters:
    ///   - client: The `Client` which will perform the download.
    public func get(using client: any Client) async throws -> T {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering get(client=\(client))\n".utf8))
        if let cached = self.cached.cachedData, let cacheUntil = self.cached.cacheDate, Date() <= cacheUntil {
            // If no-cache was set on the header, you *always* have to validate with the server.
            // must-revalidate does not require checking with the server until after it expires.
			FileHandle.standardError.write(Data("[WARN] <<< Exiting get(request=\(request))\n".utf8))
            if self.headers == nil || self.headers?.cacheControl == nil || self.headers?.cacheControl?.noCache == false {
                return cached
            }
        }

        // Don't make a new request if one is already running.
        if let request {
            // The current request may be happening on a different task.
            return try await request.value
        }

        Logger.current.debug("Requesting data from \(self.uri)")

        let newRequest = Task {
            try await self.download(using: client)
        }
        self.request = newRequest
		FileHandle.standardError.write(Data("[DEBUG] get(client=\(client)): self.request → \(self.request)\n".utf8))
        let result = try await newRequest.value
		FileHandle.standardError.write(Data("[ERROR] get(client=\(client)): result → \(result)\n".utf8))
        // Once the request finishes, clear the current request and return the data.
        self.request = nil
		FileHandle.standardError.write(Data("[WARN] <<< Exiting get(client=\(client))\n".utf8))
        return result
    }

    private func download(using client: any Client) async throws -> T {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering download(client=\(client))\n".utf8))
        // https://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html#sec13.3.4
        var headers: HTTPFields = [:]

        if let eTag = self.headers?[.eTag] {
            headers[.ifNoneMatch] = eTag
        }

        if let lastModified = self.headers?.lastModified {
            // TODO: If using HTTP/1.0 then this should be .ifUnmodifiedSince instead. Don't know
            // how to determine that right now.
            headers[.ifModifiedSince] = lastModified.serialize()
        }

        // Cache-Control max-age is calculated against the request date.
        let requestSentAt = Date()

		FileHandle.standardError.write(Data("[ERROR] download(client=\(client)): requestSentAt → \(requestSentAt)\n".utf8))
        do {
            let response = try await client.get(self.uri, headers: headers)
            if !(response.status == .notModified || response.status == .ok) {
			FileHandle.standardError.write(Data("[ERROR] download(client=\(client)): response → \(response)\n".utf8))
                throw EndpointCacheError.unexpectedResponseStatus(response.status, uri: self.uri)
            }

            if let cacheControl = response.headers.cacheControl, cacheControl.noStore == true {
                // The server *shouldn't* give an expiration with no-store, but...
                self.clearCache()
            } else {
                headers = response.headers
                self.cached.1 = headers.expirationDate(requestSentAt: requestSentAt)
            }

            switch response.status {
            case .notModified:
                Logger.current.trace("EndpointCache - cached data is still valid")
                guard let cached = self.cached.0 else {
                    // This shouldn't actually be possible, but just in case.
                    self.clearCache()
                    return try await self.download(using: client)
                }

                return cached

            case .ok:
                Logger.current.trace("EndpointCache - new data received")

                let data: T

                do {
                    data = try await response.content.decode(T.self)
                } catch {
					FileHandle.standardError.write(Data("[ERROR] Exception in download(client=\(client)): \(error)\n".utf8))
                    throw EndpointCacheError.contentDecodeFailure(error)
                }

                if self.cached.1 != nil {
                    self.cached.0 = data
                }

                return data

            default:
                // This shouldn't ever happen
				FileHandle.standardError.write(Data("[ERROR] Throwing Abort from download(client=\(client))\n".utf8))
                throw Abort(.internalServerError)
            }
        } catch {
            guard let headers = self.headers, let cached = self.cached.0 else {
                throw error
            }

            if let cacheControl = headers.cacheControl, let cacheUntil = self.cached.1 {
                if let staleIfError = cacheControl.staleIfError,
                    cacheUntil.addingTimeInterval(Double(staleIfError)) > Date() {
                    // Can use the data for staleIfError seconds past expiration when the server is non-responsive
                    return cached
                } else if cacheControl.noCache == true && cacheUntil > Date() {
                    // The spec isn't very clear here.  If no-cache is present you're supposed to validate with the
                    // server. However, if the server doesn't respond, but I'm still within the expiration time, I'm
                    // opting to say that the cache should be considered usable.
                    return cached
                }
            }

            self.clearCache()
			FileHandle.standardError.write(Data("[ERROR] Throwing error from download(client=\(client))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting download(client=\(client))\n".utf8))
            throw error
        }
    }

    private func clearCache() {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering clearCache()\n".utf8))
        self.cached = (nil, nil)
        self.headers = nil
		FileHandle.standardError.write(Data("[DEBUG] clearCache(): self.headers → \(self.headers)\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting clearCache()\n".utf8))
    }
}
