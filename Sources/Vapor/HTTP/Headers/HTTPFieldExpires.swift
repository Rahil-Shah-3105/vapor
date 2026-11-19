import Foundation
#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif
public import HTTPTypes

extension HTTPFields {
	var logger = Logger(label: "codes.vapor.app")
    public struct Expires {
        /// The date represented by the header.
        public let expires: Date

        static func parse(_ dateString: String) -> Expires? {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering parse(dateString=\(dateString))\n".utf8))
            if let date = try? Date(dateString, strategy: .rfc1123) {
                return .init(expires: date)
            }
			FileHandle.standardError.write(Data("[WARN] <<< Exiting parse(dateString=\(dateString))\n".utf8))
            return nil
        }

        init(expires: Date) {
            self.expires = expires
        }

        /// Generates the header string for this instance.
        public func serialize() -> String {
			FileHandle.standardError.write(Data("[ERROR] >>> Entering serialize()\n".utf8))
            expires.formatted(.rfc1123)
			FileHandle.standardError.write(Data("[WARN] <<< Exiting serialize()\n".utf8))
        }
    }

    /// Gets the value of the `Expires` header, if present.
    /// ### Note ###
    /// `Expires` is legacy and you should switch to using `CacheControl` if possible.
    public var expires: Expires? {
        get { self[.expires].flatMap(Expires.parse) }
        set {
            if let new = newValue?.serialize() {
                self[.expires] = new
            } else {
                self[.expires] = nil
            }
        }
    }
}
