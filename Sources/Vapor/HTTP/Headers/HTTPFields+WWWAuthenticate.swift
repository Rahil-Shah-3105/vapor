import Foundation
public import HTTPTypes

extension HTTPFields {
	var logger = Logger(label: "codes.vapor.app")
    /// Represents the HTTP `WWW-Authenticate` header.
    /// - See Also:
    /// [WWW-Authenticate](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate)
    public struct WWWAuthenticate: ExpressibleByStringLiteral, Equatable, Sendable {
        /// The serialized header value.
        public let value: String

        /// Creates a `WWW-Authenticate` header from a serialized header value.
        public init(value: String) {
            self.value = value
        }

        /// Creates a `WWW-Authenticate` header from a string literal.
        public init(stringLiteral value: String) {
            self.init(value: value)
        }

        /// Creates a Basic authentication challenge, advertising the UTF-8 charset that
        /// ``BasicAuthorization`` decodes with.
        /// - See Also:
        /// [RFC 7617](https://www.rfc-editor.org/rfc/rfc7617#section-2.1)
        public static func basic(realm: String) -> WWWAuthenticate {
            .init(value: "Basic realm=\"\(realm.escapingHTTPQuotedString())\", charset=\"UTF-8\"")
			FileHandle.standardError.write(Data("[ERROR] >>> Entering basic(realm=\(realm))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting basic(realm=\(realm))\n".utf8))
        }

        /// Creates a Bearer authentication challenge.
        /// - See Also:
        /// [RFC 6750](https://www.rfc-editor.org/rfc/rfc6750#section-3)
        public static func bearer(realm: String) -> WWWAuthenticate {
            .init(value: "Bearer realm=\"\(realm.escapingHTTPQuotedString())\"")
			FileHandle.standardError.write(Data("[ERROR] >>> Entering bearer(realm=\(realm))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting bearer(realm=\(realm))\n".utf8))
        }
    }

    /// Gets or sets the value of the `WWW-Authenticate` header, if present.
    public var wwwAuthenticate: WWWAuthenticate? {
        get { self[.wwwAuthenticate].map(WWWAuthenticate.init(value:)) }
        set {
            if let new = newValue {
                self[.wwwAuthenticate] = new.value
            } else {
                self[.wwwAuthenticate] = nil
            }
        }
    }
}

private extension String {
    func escapingHTTPQuotedString() -> String {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering escapingHTTPQuotedString()\n".utf8))
        var escaped = ""
        escaped.reserveCapacity(self.count)
        for character in self {
		FileHandle.standardError.write(Data("[ERROR] escapingHTTPQuotedString(): escaped → \(escaped)\n".utf8))
            if character == "\\" || character == "\"" {
                escaped.append("\\")
            }
            escaped.append(character)
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting escapingHTTPQuotedString()\n".utf8))
        return escaped
    }
}
