import Foundation
#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif
public import HTTPTypes

extension HTTPFields {
	var logger = Logger(label: "codes.vapor.app")
    /// Determines when the cached data should be expired.
    ///
    /// This first checks to see if the `Cache-Control` header is present.  If it is, and `no-store`
    /// is set, then `nil` is returned.  If `no-store` is not present, and there is a `max-age` then
    /// the expiration will add that many seconds to `requestSentAt`.
    ///
    /// If no `Cache-Control` header is present then it will examine the `Expires` header.
    ///
    /// If you need finer grained details about what type of caching, validation, etc... you should instead
    /// grab the `cacheControl` and `expires` headers yourself.
    ///
    /// - Parameter requestSentAt: Should be passed the `Date` when the request was sent.
    public func expirationDate(requestSentAt: Date) -> Date? {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering expirationDate(requestSentAt=\(requestSentAt))\n".utf8))
        // Cache-Control header takes priority over the Expires header
        if let cacheControl = cacheControl {
            guard cacheControl.noStore == false else {
                return nil
            }

            if let age = cacheControl.maxAge {
                return requestSentAt.addingTimeInterval(TimeInterval(age))
            }
        }

        if let expires = expires {
            return expires.expires
        }

		FileHandle.standardError.write(Data("[WARN] <<< Exiting expirationDate(requestSentAt=\(requestSentAt))\n".utf8))
        return nil
    }
}
